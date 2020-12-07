FROM tezos/tezos:v7.5
RUN sudo apk add curl lz4 xz jq
COPY tezos-node-downloader.sh /
USER root
RUN chmod a+rx /tezos-node-downloader.sh
USER tezos
ENTRYPOINT ["/tezos-node-downloader.sh"]
CMD []