FROM ubuntu:latest

RUN apt update; \
    apt upgrade -y

RUN apt-get install -y build-essential openjdk-8-jdk;\
    mkdir tars

ADD tars tars
ADD https://archive.apache.org/dist/lucene/solr/5.5.5/solr-5.5.5.tgz tars/solr-5.5.5.tgz

RUN cd tars;\
    tar xvzf solr-5.5.5.tgz;\
    mv solr-5.5.5 /opt;\
    cd /opt;\
    ln -s solr-5.5.5/ solr
    
RUN cd /tars;\
    tar xvzf mecab-0.996-ko-0.9.2.tar.gz;\
    tar xvzf mecab-ko-dic-2.0.3-20170922.tar.gz;\
    tar xvzf mecab-ko-lucene-analyzer-0.21.0.tar.gz;\
    tar xvzf mecab-java-0.996.tar.gz;\
    rm -f mecab-java-0.996/Makefile

RUN cd /tars/mecab-0.996-ko-0.9.2;\
    ./configure;\
    make;\
    make install

RUN ldconfig;\
    cd /tars/mecab-ko-dic-2.0.3-20170922;\
    ./configure;\
    make;\
    make install

COPY make_files/Makefile /tars/mecab-java-0.996/Makefile
COPY docker_entrypoint.sh /usr/bin/docker_entrypoint.sh
RUN chmod 0755 /usr/bin/docker_entrypoint.sh

RUN cd /tars/mecab-java-0.996;\
    make
RUN mv /tars/mecab-java-0.996/MeCab.jar /opt/solr/server/lib/ext;\
    mv /tars/mecab-java-0.996/libMeCab.so /usr/local/lib
    
RUN cp /tars/mecab-ko-lucene-analyzer-0.21.0/mecab-ko-mecab-loader-0.21.0.jar /opt/solr/server/lib/ext/;\
    mkdir -p /opt/solr/contrib/eunjeon/lib;\
    cp /tars/mecab-ko-lucene-analyzer-0.21.0/mecab-ko-lucene-analyzer-0.21.0.jar /opt/solr/contrib/eunjeon/lib;\
    rm -rf /tars;\
    mkdir -p /opt/solr/server/solr/cores

EXPOSE 8983

VOLUME [ "/opt/solr/server/solr/cores" ]

ENTRYPOINT [ "docker_entrypoint.sh" ]

CMD ["tail", "-f", "/opt/solr/server/logs/solr.log"]