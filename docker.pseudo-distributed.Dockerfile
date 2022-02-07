FROM ubuntu:20.04
LABEL MAINTAINER="Junior-Steve ESSONO ELLA <junioressono@gmail.com>"

RUN apt-get update -y
RUN apt-get install -y apt-utils
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y wget
RUN apt-get install -y openssh-server
RUN apt-get install -y net-tools

# Setup passphraseless ssh
RUN  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
     cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
     chmod 0600 ~/.ssh/authorized_keys

WORKDIR /root
COPY ./data/hadoop/hadoop-3.3.1-aarch64.tar.gz .
#RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1-aarch64.tar.gz && \
RUN tar -xzvf hadoop-3.3.1-aarch64.tar.gz && \
    mv hadoop-3.3.1 /usr/local/hadoop && \
    rm hadoop-3.3.1-aarch64.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin

COPY config/hadoop/ssh_config .ssh/config
COPY config/hadoop/start-hadoop.sh start-hadoop.sh

# Allow start-hadoop file to be executable
RUN chmod +x $HADOOP_HOME/etc/hadoop/*.sh && \
    chmod +x ~/start-hadoop.sh

# Create namenode, datanode and logs folders
RUN mkdir -p ~/hdfs/namenode && \
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# Format namenode
RUN $HADOOP_HOME/bin/hdfs namenode -format

#ENTRYPOINT [ "sh", "-c", "service ssh start; ~/start-hadoop.sh; bash" ]
#CMD [ "sh", "-c", "service ssh start; ~/start-hadoop.sh; bash" ]
CMD [ "sh", "-c", "service ssh start; bash" ]