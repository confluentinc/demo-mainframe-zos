# Introduction
This document details the steps automated by the scripts in the repository. It serves as an implementation guide for Confluent Connect on Z, specifically using the IBM MQ source/sink connectors. This solution will run the connect framework and connectors in zIIP space, in bindings mode. 


# Assumptions and Pre-Work
You will need to know some information about the environment and will likely need to work with other teams in your org for security, user administration, Kafka endpoints and MQ SMEs. This guide assumes you have zOS v2r4 or newer, Java 8 or 10 (know the version and the path) and zIIP access. You will additionally need to have access to:

-SSH/SFTP (with associated ports, usually 22 and/or 443)
-USS (with a user that can r/w/x from their home)
-USS User should have 5G of disk space and a 2G Java Heap
-Ports for Confluent (8082, 8083)
-What is the QMGR and QUEUE name?
-What is the Kafka info (bootstrap, key, secret)?
-What is the Java path? (e.g. /usr/lpp/mqm/V9R1M0/java/lib) 

_Files to run Connect on Z_
1. Ensure libmqjbnd.so libmqjbnd64.so are in /java/lib and /java64/lib/ respectively. 
1. Get the MQ All Client JAR from IBM and put it in /java/lib/ (com.ibm.mq.allclient.jar)
1. Download the IBM MQ Source and Sink connectors for z/OS from Confluent Hub. Extract them in your USS home dir. 
1. Download the Connect on z/OS tar file. Extract it in your USS home dir. 

# Configure and Launch

There are three main files involved. They are all in the Connect sub directory, where you extracted them in the pre-work. For example /u/confluent/confluent-connect. Move to that directory and you will see /bin and /etc, which are the only two directories in scope. 

Inside /bin, we want to edit connect-standalone.properties. This file sets up the Connect framework itself, including the endpoint to produce to, credentials and path info. You will need the boostrap, key and secret from the destination Kafka cluster. For example Confluent Cloud or self-managed Confluent Platform. 

    bootstrap.servers=YOUR_KAFKA_BOOTSTRAP:9092
    key.converter=org.apache.kafka.connect.storage.StringConverter
    value.converter=org.apache.kafka.connect.storage.StringConverter
    
    # Authentication settings for Connect producers used with source connectors
    producer.ssl.keystore.location=/var/private/ssl/kafka.source.keystore.jks
    producer.ssl.keystore.password=connector1234
    producer.ssl.key.password=connector1234
    
    # Authentication settings for Connect consumers used with sink connectors
    consumer.ssl.keystore.location=/var/private/ssl/kafka.sink.keystore.jks
    consumer.ssl.keystore.password=connector1234
    consumer.ssl.key.password=connector1234
    
    ssl.endpoint.identification.algorithm=https
    security.protocol=SASL_SSL
    sasl.mechanism=PLAIN
    sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="YOUR_KEY" password="YOUR_SECRET";
    request.timeout.ms=20000
    retry.backoff.ms=500
    
    producer.bootstrap.servers=YOUR_KAFKA_BOOTSTRAP:9092
    producer.ssl.endpoint.identification.algorithm=https
    producer.security.protocol=SASL_SSL
    producer.sasl.mechanism=PLAIN
    producer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="YOUR_KEY" password="YOUR_SECRET";
    producer.request.timeout.ms=20000
    producer.retry.backoff.ms=500
    
    consumer.bootstrap.servers=YOUR_KAFKA_BOOTSTRAP:9092
    consumer.ssl.endpoint.identification.algorithm=https
    consumer.security.protocol=SASL_SSL
    consumer.sasl.mechanism=PLAIN
    consumer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="YOUR_KEY" password="YOUR_SECRET";
    consumer.request.timeout.ms=20000
    consumer.retry.backoff.ms=500
    
    offset.flush.interval.ms=1000
    offset.storage.file.filename=/tmp/connect.offsets

# Path to plugins (from pre-work)
plugin.path=/path/to/java,/path/to/mqsource/connector,/path/to/mqsource/connector

The next file we will look at is the source properties file. Move up a directory from bin/ and go into etc/kafka and create a file called mqsource.properties. This file will contain the information that is needed to consume MQ messages from a specified queue manager and queue and tell which Kafka topic it should be written to. 


    name = test.mq.source.connector
    connector.class = io.confluent.connect.ibm.mq.IbmMQSourceConnector
    key.converter=org.apache.kafka.connect.storage.StringConverter
    value.converter=org.apache.kafka.connect.storage.StringConverter
    
    mq.hostname = " "
    mq.queue.manager = YOUR_QMGR_NAME
    mq.channel = " "
    mq.transport.type=bindings
    jms.destination.name = YOUR_QUEUE_NAME
    
    jms.destination.type = queue
    
    kafka.topic = DESTINATION_TOPIC_NAME
    
    #You can tune these as needed
    tasks.max=5
    receiver.threads=5
    
    batch.size=5000
    max.pending.messages=5000
    max.poll.duration=5000

Likewise, to sink, or send messages into MQ, you will need similar configuration. In etc/kafka, make a second file, called mq-sink.properties. You will need the name of the Kafka topic you will consume from and the information for the queue you will produce to.


    name = test.mq.sink.connector
    
    connector.class=io.confluent.connect.jms.IbmMqSinkConnector
    key.converter=org.apache.kafka.connect.storage.StringConverter
    value.converter=org.apache.kafka.connect.storage.StringConverter
    
    mq.hostname=""
    mq.channel=*
    mq.queue.manager=YOUR_QMGR_NAME
    mq.transport.type=bindings
    topics=DESTINATION_TOPIC_NAME
    
    jms.destination.name=YOUR_QUEUE_NAME
    jms.destination.type=queue
    
    mq.user.name="IF_NEEDED"
    mq.password="IF_NEEDED"
    To begin consuming messages from the local MQ queue and producing them to Kafka, change back to bin/ and:
    
    ./connect-standalone ../etc/kafka/connect-standalone.properties ../etc/kafka/mq-source.properties

To begin consuming messages from Kafka and producing them to the local MQ queue, change back to bin/ and:

    ./connect-standalone ../etc/kafka/connect-standalone.properties ../etc/kafka/mq-source.properties


But you should ultimately run as a JOB and not as a USER. So here’s an EXAMPLE JCL FILE

Example connector.properties file, in distributed mode 

    {
        "name": "ABCCORP.OMS.TRADEFLOW.Q01",
        "config": {
        "connector.class": "io.confluent.connect.ibm.mq.IbmMQSourceConnector",
        "kafka.topic": "ABCCORP.TRADEFLOW.TP0",
        "jms.destination.name": "QUEUE.NAME.Q01",
        "tasks.max": "10",
        "mq.hostname": " ",
        "mq.transport.type": "bindings",
        "mq.queue.manager": "xxxx",
        "mq.channel": " ",
        "mq.user.name": "user-name",
        "max.pending.messages": "1000",
        "batch.size": "1000",
        "max.poll.duration": "1000",
        "jms.destination.type": "queue",
        "confluent.topic.bootstrap.servers":"kafka.cluster.broker01.abccorp.com:9092",
        "confluent.license": "..",
        "confluent.topic.replication.factor": "1",
        "value.converter": "org.apache.kafka.connect.storage.StringConverter",
        "value.converter.schemas.enable": "false",
        "key.converter": "org.apache.kafka.connect.storage.StringConverter",
        "key.converter.schemas.enable": "false"
    }

The connector specific config properties are defined here. Please note that running in distributed mode is with posture to distributing across kafka connect workers but not across queues or qmanagers. The connector will still expect discrete queues and qmanagers to connect to. If 1 qmanager extends across LPARs, the connector will function fine; however, if for example you have 2 qmanagers across LPARs, then it would require 2 distinct MQ on Z connectors. 
