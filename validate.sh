#!/bin/bash

trap "" HUP

#if [ $EUID -eq 0 ]; then
#   echo "this script must not be run as root. su to hdfs user to run"
#   exit 1
#fi

MR_EXAMPLES_JAR=/opt/cloudera/parcels/CDH/jars/hadoop-mapreduce-examples-2.6.0-cdh5.15.3-SNAPSHOT.jar

# SIZE=1T
# SIZE=500G
# SIZE=100G
# SIZE=10G
SIZE=1G


LOGDIR=logs

if [ ! -d "$LOGDIR" ]
then
    mkdir ./$LOGDIR
fi

DATE=`date +%Y-%m-%d:%H:%M:%S`

RESULTSFILE="./$LOGDIR/teravalidate_results_$DATE"


OUTPUT=/tmp/${SIZE}-terasort-output
REPORT=/tmp/${SIZE}-terasort-report


# teravalidate.sh
# Kill any running MapReduce jobs
mapred job -list | grep job_ | awk ' { system("mapred job -kill " $1) } '
# Delete the output directory
hadoop fs -rm -r -f -skipTrash ${REPORT}
# Run teravalidate
time hadoop jar $MR_EXAMPLES_JAR teravalidate \
-Ddfs.blocksize=256M \
-Dio.file.buffer.size=131072 \
-Dmapreduce.map.memory.mb=2048 \
-Dmapreduce.map.java.opts=-Xmx1536m \
-Dmapreduce.reduce.memory.mb=2048 \
-Dmapreduce.reduce.java.opts=-Xmx1536m \
-Dyarn.app.mapreduce.am.resource.mb=1024 \
-Dyarn.app.mapreduce.am.command-opts=-Xmx768m \
-Dmapreduce.task.io.sort.mb=1 \
-Dmapred.map.tasks=185 \
-Dmapred.reduce.tasks=185 \
${OUTPUT} ${REPORT} >> $RESULTSFILE 2>&1
