FROM spark:3.5.1

# Install Dependencies
USER root
RUN apt-get update\
  && apt-get install -y --no-install-recommends curl unzip ssh\
  && apt-get clean\
  && rm -rf /var/lib/apt/lists/*

# Setup Spark directory and path
ENV SPARK_HOME=/opt/spark
ENV PATH="${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"

RUN mkdir -p ${SPARK_HOME}/conf

# Setup Hadoop directory and path
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_VERSION=hadoop-3.4.0
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"

RUN mkdir -p ${HADOOP_HOME}

# Download Hadoop
RUN curl https://dlcdn.apache.org/hadoop/common/${HADOOP_VERSION}/${HADOOP_VERSION}.tar.gz -o ${HADOOP_VERSION}-bin.tar.gz\
  && tar xfz ${HADOOP_VERSION}-bin.tar.gz --directory /opt/hadoop --strip-components 1\
  && rm -rf ${HADOOP_VERSION}-bin.tar.gz

ENV LD_LIBRARY_PATH=${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH}
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> "${HADOOP_HOME}/etc/hadoop/hadoop-env.sh"

# Setup SSH for Hadoop
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 600 ~/.ssh/authorized_keys

COPY ssh_config ~/.ssh/config
EXPOSE 22

# Copy Hadoop Configs
COPY ./yarn/*.xml ${HADOOP_HOME}/etc/hadoop

# Add Additional Jars for Spark
COPY jars/*.jar ${SPARK_HOME}/jars/

# Set Entrypoint
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
