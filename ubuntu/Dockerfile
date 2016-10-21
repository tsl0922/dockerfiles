FROM ubuntu:16.04

# install packages
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends software-properties-common ca-certificates curl unzip vim wget && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends oracle-java8-installer ca-certificates-java git && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# configure locale
RUN echo "Asia/Shanghai" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen && \
    dpkg-reconfigure -f noninteractive locales

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# git config
RUN git config --global pack.windowMemory "256m" && \
    git config --global pack.threads "1" && \
    git config --global pack.packSizeLimit "256m"
