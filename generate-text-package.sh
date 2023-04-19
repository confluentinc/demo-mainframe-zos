. ./env.sh

mkdir text-package
cp text-package.IN/* text-package

cat ./configure/connect-standalone.properties.IN | \
    sed -e "s^YOUR_API_KEY^$API_KEY^g" \
        -e "s^YOUR_API_SECRET^$API_SECRET^g" \
        -e "s^YOUR_SOURCE_CONNECTOR^$SOURCE_CONNECTOR_PATH^g" \
        -e "s^YOUR_SINK_CONNECTOR^$SINK_CONNECTOR_PATH^g" \
        -e "s^YOUR_BOOTSTRAP_SERVER^$BOOTSTRAP_SERVER^g" > text-package/connect-standalone.properties

cat ./connect/mq-sink.properties.IN | \
    sed -e "s^YOUR_MQ_SINK_TOPIC^$SINK_CONNECTOR_TOPIC^g" \
        -e "s^YOUR_QUEUE^$SINK_CONNECTOR_QUEUE^g" > text-package/mq-sink.properties 

cat ./connect/mq-source.properties.IN | \
    sed -e "s^YOUR_MQ_SOURCE_TOPIC^$SOURCE_CONNECTOR_TOPIC^g" \
        -e "s^YOUR_QUEUE^$SOURCE_CONNECTOR_QUEUE^g" > text-package/mq-source.properties

cat ./connect/run-connect-source.sh.IN | \
    sed -e "s^YOUR_LIB_PATH^$LIBPATH^g" > text-package/run-connect-source.sh

cat ./connect/run-connect-sink.sh.IN | \
    sed -e "s^YOUR_LIB_PATH^$LIBPATH^g" > text-package/run-connect-sink.sh
