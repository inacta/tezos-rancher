FROM tezos/tezos:v8.2
RUN sudo apk add curl lz4 xz jq
COPY tezos-node-downloader.sh /
USER root
RUN chmod a+rx /tezos-node-downloader.sh
USER tezos
ENTRYPOINT ["/tezos-node-downloader.sh"]
CMD []