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

# Update kubernetes-client (SPARK-28925)
RUN rm -f ${SPARK_HOME}/jars/kubernetes-client-*.jar
ADD https://repo1.maven.org/maven2/io/fabric8/kubernetes-client/4.4.2/kubernetes-client-4.4.2.jar ${SPARK_HOME}/jars

# output of $(hadoop classpath) + tools lib
ENV SPARK_DIST_CLASSPATH=/opt/hadoop/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/mapreduce/lib/*:/opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/share/hadoop/yarn:/opt/hadoop/share/hadoop/yarn/lib/*:/opt/hadoop/share/hadoop/yarn/*:/opt/hadoop/share/hadoop/tools/lib/*

WORKDIR ${SPARK_HOME}/work-dir

ENTRYPOINT ["/opt/entrypoint.sh"]
