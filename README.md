# Tezos Node on Rancher

This repository deploys a public Tezos node (v7.5) on Rancher.

## Docker Images
The deployment command will run two init containers in sequence before starting the node itself.

**tezos-node-configurator**: Sets pre-defined parameters such as network, protocol, history-mode, client-config.

**tezos-node-downloader**: If node-data is not already available on the persistent volume then it downloads and imports a full snapshot from https://snapshots-tezos.giganode.io/. The current snapshot link is from **Dec. 7. 2020**.
The link to the full snapshot can be found in **values-mainnet.yaml** and **values-testnet.yaml** under ```tezos.FULL_SNAPSHOT_URL```.

### Build images
The init containers have to be built and pushed to a container repository before deployment. The path to each container has to be referenced in ```statefulset.yaml > initContainers.image```

```docker build -t tezos-node-configurator:latest .```

```docker build -t tezos-node-downloader:latest .```

## Deployment

Assuming that kube config is set up correctly the node can be deployed with one of the following commands.

```helm upgrade --install tezos-node-testnet charts/tezos/ -n tezos-node-delphinet --values charts/tezos/values-testnet.yaml```

```helm upgrade --install tezos-node-mainnet charts/tezos/ -n tezos-node-mainnet --values charts/tezos/values-mainnet.yaml```

The tezos container will start once the init containers are terminated. **tezos-node-configurator** may take several hours to complete as it retrieves and validates data from the snapshot.

## Volume
A persistent volume with 100GiB is attached to the container that is mounted with **/var/run/tezos**. This contains all **tezos-client** and **tezos-node** data.

## Upcoming features
* Baking service
* Remote signing service
* Rewards payment service

## Sources
* https://tezos.gitlab.io
* https://github.com/midl-dev/tezos-on-gke
* https://github.com/blockchain-etl/tezos-kubernetes
* https://snapshots-tezos.giganode.io

