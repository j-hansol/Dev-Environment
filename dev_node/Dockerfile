FROM node:latest

COPY docker_entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

RUN mkdir /home/app

VOLUME [ "/home/app" ]

EXPOSE 80 8080

ENTRYPOINT [ "docker_entrypoint.sh" ]

CMD ["bash"]
