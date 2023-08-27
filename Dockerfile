FROM ubuntu:22.04

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get update && apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev

WORKDIR /app

RUN mkdir -p download

# python 설치
RUN cd download && wget https://www.python.org/ftp/python/3.9.17/Python-3.9.17.tgz \
	&& tar xzvf Python-3.9.17.tgz \
	&& rm Python-3.9.17.tgz \
	&& cd Python-3.9.17 \
	&& ./configure --enable-optimizations \
	&& make -j$(nproc) \
	&& make altinstall

RUN update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 1

# java 설치
RUN cd download && wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz \
	&& tar xzfv openjdk-11.0.2_linux-x64_bin.tar.gz \
	&& rm openjdk-11.0.2_linux-x64_bin.tar.gz

ENV JAVA_HOME="/app/download/jdk-11.0.2"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# spark 설치
RUN cd download && wget https://dlcdn.apache.org/spark/spark-3.4.1/spark-3.4.1-bin-hadoop3.tgz \
	&& tar xzfv spark-3.4.1-bin-hadoop3.tgz \
	&& rm spark-3.4.1-bin-hadoop3.tgz

ENV SPARK_HOME="/app/download/spark-3.4.1-bin-hadoop3"
ENV PATH="${SPARK_HOME}/bin:${PATH}"

ENV PYTHONPATH="${SPARK_HOME}/python/:$PYTHONPATH"
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.9.7-src.zip:${PYTHONPATH}"

EXPOSE 4040