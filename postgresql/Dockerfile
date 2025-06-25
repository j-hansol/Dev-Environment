FROM postgres:17

# pgvector 설치에 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    postgresql-server-dev-17 \
    make g++ git \
    && git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git \
    && cd pgvector && make && make install \
    && cd .. && rm -rf pgvector \
    && apt-get remove --purge -y make g++ git \
    && apt-get autoremove -y && apt-get clean
