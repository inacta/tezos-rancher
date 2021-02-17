FROM ubuntu:18.04

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y git sudo apt-utils software-properties-common python3.8 python3-pip jq curl

RUN mkdir -p /tezos

RUN cd /tezos && \
    sudo add-apt-repository ppa:serokell/tezos && \
    sudo apt-get install -y tezos-client

RUN cd /tezos && \
    sudo add-apt-repository ppa:deadsnakes/ppa && \
    git clone https://github.com/tezos-reward-distributor-organization/tezos-reward-distributor && \
    pip3 install -r /tezos/tezos-reward-distributor/requirements.txt
    
RUN mkdir -p /tezos/pymnt/cfg/ 
COPY tz1boot1pK9h2BVGXdyvfQSv8kd1LQM6H889.yaml /tezos/pymnt/cfg/

COPY tezos-client-config.sh /tezos
RUN chmod u+x /tezos/tezos-client-config.sh
RUN ./tezos/tezos-client-config.sh

COPY trd-init.sh /tezos
RUN chmod u+x /tezos/trd-init.sh

ENTRYPOINT [ "./tezos/trd-init.sh" ]
CMD []