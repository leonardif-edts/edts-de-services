#!/bin/sh

echo "SPARK_MODE: $SPARK_MODE"

/etc/init.d/ssh start

if [ "$SPARK_MODE" = "master" ]
then
    hdfs namenode -format

    # Start Master Node
    hdfs --daemon start namenode
    hdfs --daemon start secondarynamenode
    yarn --daemon start resourcemanager

    # Create Required Directory
    while ! hdfs dfs -mkdir -p /spark-logs;
    do
        echo "Failed creating /spark-logs hdfs dir"
    done
    echo "Created /spark-logs hdfs dir"
    hdfs dfs -mkdir -p /opt/spark/data
    echo "Created /opt/spark/data hdfs dir"

    # Copy Data from HDFS
    hdfs dfs -copyFromLocal /opt/spark/data/* /opt/spark/data
    hdfs dfs -ls /opt/spark/data

elif [ "$SPARK_MODE" = "worker" ]
then
    hdfs namenode -format

    # Start Worker Node
    hdfs --daemon start datanode
    yarn --daemon start nodemanager

elif [ "$SPARK_MODE" = "history" ]
then
    while ! hdfs dfs -test -d /spark-logs;
    do
        echo "spark-logs doesn't exist yet... retrying"
        sleep 1;
    done
    echo "spark-logs created"
    echo "Exit loop"

    # Start Spark History
    start-history-server.sh
elif [ "$SPARK_MODE" = "local" ]
then
    echo "Idling..."
fi

tail -f /dev/null