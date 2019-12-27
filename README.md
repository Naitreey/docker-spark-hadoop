# docker-spark-hadoop
*Project status*: alpha.

Spark image built with [official instructions](https://spark.apache.org/docs/latest/running-on-kubernetes.html#docker-images) presents several problems:

-   Does not support `s3a://` urls for application and dependency jars.
    Application has to build custom Docker image to bundle application jar. 
-   Built with Scala 2.11, rather than 2.12. Although Spark officially provides
    Scala 2.12 version of distribution, it doesn't include Hadoop dependencies.

This image addresses these issues.

## How to build
1.  Download and extract Hadoop binary distribution (*any version above 2.8*)
    into `build/` directory. Rename it as `hadoop`.
2.  Download and extract Spark binary distribution (*without pre-packaged
    Hadoop dependencies*) into `build/` directory. Rename it as `spark`.
3.  Build Spark image:

    ```sh
    docker build -t <tag> -f Dockerfile .
    ```
