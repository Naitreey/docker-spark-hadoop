FROM openjdk:8-alpine

ARG spark_base=build/spark
ARG hadoop_base=build/hadoop

ARG spark_jars=jars
ARG img_path=kubernetes/dockerfiles
ARG k8s_tests=kubernetes/tests

ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV SPARK_HOME=/opt/spark

RUN set -ex \
    && apk upgrade --no-cache \
    && ln -s /lib /lib64 \
    && apk add --no-cache bash tini libc6-compat linux-pam nss \
    && mkdir -p ${SPARK_HOME}/work-dir \
    && touch ${SPARK_HOME}/RELEASE \
    && rm /bin/sh \
    && ln -sv /bin/bash /bin/sh \
    && echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su \
    && chgrp root /etc/passwd && chmod ug+rw /etc/passwd

COPY ${hadoop_base} ${HADOOP_HOME}

COPY ${spark_base}/${spark_jars} ${SPARK_HOME}/jars
COPY ${spark_base}/bin ${SPARK_HOME}/bin
COPY ${spark_base}/sbin ${SPARK_HOME}/sbin
COPY ${spark_base}/${img_path}/spark/entrypoint.sh /opt/
COPY ${spark_base}/examples ${SPARK_HOME}/examples
COPY ${spark_base}/${k8s_tests} ${SPARK_HOME}/tests
COPY ${spark_base}/data ${SPARK_HOME}/data

# override entrypoint
COPY entrypoint.sh /opt/entrypoint.sh

# Update kubernetes-client (SPARK-28925)
RUN rm -f ${SPARK_HOME}/jars/kubernetes-client-*.jar
ADD https://repo1.maven.org/maven2/io/fabric8/kubernetes-client/4.4.2/kubernetes-client-4.4.2.jar ${SPARK_HOME}/jars

# output of $(hadoop classpath) + tools lib
ENV SPARK_DIST_CLASSPATH=/opt/hadoop/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/mapreduce/lib/*:/opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/share/hadoop/yarn:/opt/hadoop/share/hadoop/yarn/lib/*:/opt/hadoop/share/hadoop/yarn/*:/opt/hadoop/share/hadoop/tools/lib/aliyun-java-sdk-core-3.4.0.jar:/opt/hadoop/share/hadoop/tools/lib/aliyun-java-sdk-ecs-4.2.0.jar:/opt/hadoop/share/hadoop/tools/lib/aliyun-java-sdk-ram-3.0.0.jar:/opt/hadoop/share/hadoop/tools/lib/aliyun-java-sdk-sts-3.0.0.jar:/opt/hadoop/share/hadoop/tools/lib/aliyun-sdk-oss-3.4.1.jar:/opt/hadoop/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:/opt/hadoop/share/hadoop/tools/lib/azure-data-lake-store-sdk-2.2.9.jar:/opt/hadoop/share/hadoop/tools/lib/azure-keyvault-core-1.0.0.jar:/opt/hadoop/share/hadoop/tools/lib/azure-storage-7.0.0.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-aliyun-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-archive-logs-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-archives-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-aws-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-azure-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-azure-datalake-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-datajoin-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-distcp-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-extras-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-fs2img-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-gridmix-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-kafka-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-openstack-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-resourceestimator-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-rumen-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-sls-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.2.1.jar:/opt/hadoop/share/hadoop/tools/lib/jdom-1.1.jar:/opt/hadoop/share/hadoop/tools/lib/lz4-1.2.0.jar:/opt/hadoop/share/hadoop/tools/lib/ojalgo-43.0.jar:/opt/hadoop/share/hadoop/tools/lib/wildfly-openssl-1.0.7.Final.jar

WORKDIR ${SPARK_HOME}/work-dir

ENTRYPOINT ["/opt/entrypoint.sh"]
