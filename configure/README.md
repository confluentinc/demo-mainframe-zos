In this section we install Connect on Z on the mainframe.

Connect on Z includes Kafka Connect and configuration files for
standalone and distributed connectors.

https://docs.confluent.io/platform/current/connect/connect-zos.html

All client jar at
https://docs.confluent.io/kafka-connect-ibmmq-sink/current/#ibmmq-client-jar

https://www.ibm.com/docs/en/ibm-mq/9.0?topic=jms-obtaining-mq-classes-separately

Edit env.sh.template to include your API key, bootstrap server, plugin paths, kafka topic and queue. 

Extract the Connect on Z tar file
unzip the connectors

tar xvf confluent-connect-7.3.0-zOS.tar
unzip confluentinc-kafka-connect-ibmmq-zos-10.2.0.zip
unzip confluentinc-kafka-connect-ibmmq-zos-sink-2.1.2.zip
Place the all client in the connector directories
cp com.ibm.mq.allclient.jar confluentinc-kafka-connect-ibmmq-zos-10.2.0/lib
cp com.ibm.mq.allclient.jar confluentinc-kafka-connect-ibmmq-zos-sink/lib

Run gen-config.sh to produce packages

connect-standalone.properties - include the API key, bootstrap server and the plugin path
source.properties
sink.properties


use sftp for the binaries
sftp -P 2022 ibmuser@34.222.94.162
mkdir cflt-zos
cd cflt-zos
put -r bin-package

scp for the text - the properties files, or just copy and paste them
scp -P -r text-package ibmuser@34.222.94.162:~/cflt-zos

Locate the shared objects required by the connectors and the all client
and place them in LIB_PATH


Start:
export LIB_PATH=$LIB_PATH:path_to_lib
./connect-standalone ../etc/kafka/connect-standalone.properties ../etc/kafka/mq-source.properties

