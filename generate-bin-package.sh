mkdir bin-package
tar xvf bin-package.IN/confluent-connect-7.3.0-zOS.tar -C bin-package
unzip bin-package.IN/confluentinc-kafka-connect-ibmmq-zos-10.2.0.zip -d bin-package
unzip bin-package.IN/confluentinc-kafka-connect-ibmmq-zos-sink-2.1.2.zip -d bin-package

mv bin-package/confluentinc-kafka-connect-ibmmq-10.2.0 bin-package/mq-source
mv bin-package/confluentinc-kafka-connect-ibmmq-sink-2.1.2 bin-package/mq-sink
mv bin-package/confluent-connect-7.3.0-zOS bin-package/connect
cp bin-package.IN/com.ibm.mq.allclient.jar bin-package/mq-source/lib
cp bin-package.IN/com.ibm.mq.allclient.jar bin-package/mq-sink/lib

 
