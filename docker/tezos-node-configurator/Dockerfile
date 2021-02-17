FROM tezos/tezos:v8.2
COPY tezos-node-configurator.sh /
USER root
RUN chmod a+rx /tezos-node-configurator.sh
USER tezos
ENTRYPOINT ["/tezos-node-configurator.sh"]
CMD []