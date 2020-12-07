FROM tezos/tezos:v7.5
COPY tezos-node-configurator.sh /
USER root
RUN chmod a+rx /tezos-node-configurator.sh
USER tezos
ENTRYPOINT ["/tezos-node-configurator.sh"]
CMD []