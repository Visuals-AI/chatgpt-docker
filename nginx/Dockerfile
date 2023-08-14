FROM expm02/ubuntu-gcc-cmake-docker:latest

ARG VUL_DIR
ENV VUL_DIR ${VUL_DIR}

ADD "${VUL_DIR}/docker-entrypoint.sh" /bin/.docker-entrypoint.sh
RUN chmod 100 /bin/.docker-entrypoint.sh