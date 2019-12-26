# docker-spark-hadoop
*Project status*: alpha.

Spark image built with [official instructions](https://spark.apache.org/docs/latest/running-on-kubernetes.html#docker-images) presents several problems:

-   Does not support `s3a://` urls for application and dependency jars.
    Application has to build custom Docker image to bundle application jar. 
-   Built with Scala 2.11, rather than 2.12. Although Spark officially provides
    Scala 2.12 version of distribution, it doesn't include Hadoop dependencies.

This image addresses these issues.
