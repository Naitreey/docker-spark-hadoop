FROM openjdk:8-alpine

ARG spark_base=build/spark

ARG spark_jars=jars
ARG img_path=kubernetes/dockerfiles
ARG k8s_tests=kubernetes/tests

RUN set -ex && \
    apk upgrade --no-cache && \
    ln -s /lib /lib64 && \
    apk add --no-cache bash tini libc6-compat linux-pam nss && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd

COPY ${spark_base}/${spark_jars} /opt/spark/jars
COPY ${spark_base}/bin /opt/spark/bin
COPY ${spark_base}/sbin /opt/spark/sbin
COPY ${spark_base}/${img_path}/spark/entrypoint.sh /opt/
COPY ${spark_base}/examples /opt/spark/examples
COPY ${spark_base}/${k8s_tests} /opt/spark/tests
COPY ${spark_base}/data /opt/spark/data

# Update kubernetes-client (SPARK-28925)
RUN rm -f /opt/spark/jars/kubernetes-client-*.jar
ADD https://repo1.maven.org/maven2/io/fabric8/kubernetes-client/4.4.2/kubernetes-client-4.4.2.jar /opt/spark/jars

# Add aws dependencies
ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.7/hadoop-aws-2.7.7.jar /opt/spark/jars
ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.699/aws-java-sdk-bundle-1.11.699.jar /opt/spark/jars

ENV SPARK_HOME /opt/spark

WORKDIR /opt/spark/work-dir

ENTRYPOINT ["/opt/entrypoint.sh"]
