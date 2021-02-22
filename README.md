# Tezos Baker Node for Rancher

This repository deploys a Tezos node and baker (v8.2) on Rancher with an optional payment service.

## Pre-requisites

The underling infrastructure is not in scope for this project. It is assumed that the user is familiar with and has a working setup of the following tools and modules.
* [Rancher](https://rancher.com/) (known to work with v2.4.6)
* [longhorn](https://longhorn.io/docs/0.8.0/install/install-with-rancher/)
* [docker](https://docs.docker.com/get-docker/)
* [helm](https://helm.sh/docs/intro/install/) (known to work with v3.3.1)
* [kubectl](https://kubernetes.io/de/docs/tasks/tools/install-kubectl/) (known to work with Client v1.19.0)
* kube config
* a docker registry (such as [Artifactory](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory))

## Docker Images

**tezos-node:**

Handles chain data. It will process the provided snapshot file and synchronize the rest to be up-to-date.

**tezos-baker:**

Needs a funded address (min. XTZ 8000/ 1 roll) in /var/run/tezos/client with access to its private keys for signing transactions.

**tezos-endorser:**

During initialization runs tezos-endorser command.

**tezos-accuser:**

During initialization runs tezos-accuser command.

**tezos-node-configurator:** 

Sets pre-defined parameters such as network, protocol, history-mode, client-config.

**tezos-node-downloader:** 

If node-data is not already available on the persistent volume then it downloads and imports a full snapshot from [Tezos Giga Node](https://snapshots-tezos.giganode.io/). This has to be updated to the latest snapshot.
The link to the full snapshot can be found in **values-mainnet.yaml** and **values-testnet.yaml** under ```tezos.FULL_SNAPSHOT_URL```.

**tezos-payment-service**: This image runs separatly from the baker deployment. Make sure to configure ```tz1boot1pK9h2BVGXdyvfQSv8kd1LQM6H889.yaml``` and ```trd-init.sh``` to your baker before building the image. 
More information to the configuration options can be found at [Tezos Reward Distribution](https://tezos-reward-distributor-organization.github.io/tezos-reward-distributor/configuration.html).

It is recommended to use a second wallet, that is separate from the baker's, for reward payments only. The payment wallet can also be delegated to the baker in order to fully utilize funds.

### Build images
The init containers (tezos-node-configurator & tezos-node-downloader) have to be built and pushed to a container repository before deployment. The path to each container has to be referenced in the values-(mainnet/delphinet).yaml file at ```initContainers.configurator_image``` and ```initContainers.downloader_image``` respectively.

## Deployment

Using the helm chart the tezos containers will start once the init containers are terminated. **tezos-node-configurator** may take several hours to complete as it retrieves and validates data from the snapshot.

When the node is started for the first time the tezos-baker container might get into a loop. This is due to the missing ```tezos.baker_alias``` and ```tezos.baker_address``` values in the yaml file. Follow the steps in **Create Wallet for Baker** and restart the instance in Rancher.

If **tezos-payment-service** is also deployed ```./trd-init.sh``` has to be run manually from the container to start calculations and report generation. If it should start automatically then add ```RUN ./tezos/trd-init.sh``` to the dockerfile.

## Volumes
The following persistent volume claims are issued.


| Name        | Size  | Mapping        |
| ------------|:-----:| ---------------|
| tezos-pvc   | 100G  | /var/run/tezos |
| workdir-pvc | 5G    | /home/tezos    |

```tezos-pvc``` will contain node settings and chain data while ```workdir-pvc``` is reserved for tezos-client data such as the keys for the baker wallet.

**tezos-payment-service** generates calculations and payment reports in csv format for each cycle. An additional PVC mapping can be made for ```tezos/pymnt/reports```

## Create Wallet for Baker
Open a shell to tezos-node.

**Step 1:**

```tezos-signer gen keys <your_baker_alias> --encrypted```

Enter a password for the Encryption and confirm it.

**Step 2:**

```tezos-signer show address <your_baker_alias> --show-secret```

This will display the Hash, Public Key and Secret Key for the new wallet. Save a copy to a secure location.

**Step 3:**

Open a second, separate terminal and start the signer socket.

```tezos-signer launch local signer -s /home/tezos/.tezos-signer/socket```

It will prompt for the password that was set during **Step 1**.

**Step 4:**

Go back to the first Terminal and import the keys into tezos-client. (Replace tz1... with the Hash from **Step 2**.)

```tezos-client import secret key <your_baker_alias> unix:/home/tezos/.tezos-signer/socket?pkh=<your_baker_address>```

If this would fail try the same command again by force adding -f at the end.

When successful a message will display *Tezos address added: <your_baker_address>*

### Register Baker
The wallet is now ready to receive funds and sign transactions. You can test signing with a dry-run command:

```tezos-client sign bytes 0x03 for <your_baker_alias>```

Please note, that some wallets may not be able to send funds to this address before its key has been revealed. In this case try to send a nominal amount from another address (e.g: Galleon) and run the following command:

```tezos-client reveal key for <your_baker_alias>```

Once the wallet is funded it can be registered as a baker. The fee amount may vary.

```tezos-client register key <your_baker_alias> as delegate --fee 0.259```

### Restart
When the tezos-baker-service is restarted for any reason the connection to the signer socket will not re-establish automatically. 

**Step 1:**

Clear tezos-client of the imported baker address and remove the existing socket. Use the following commands.

```rm -rf /var/run/tezos/client/public_key_hashs```

```rm -rf /var/run/tezos/client/public_keys```

```rm -rf /var/run/tezos/client/secret_keys```

```rm -rf /home/tezos/.tezos-signer/socket```

**Step 2:**

Open a second, separate terminal and start the signer socket.

```tezos-signer launch local signer -s /home/tezos/.tezos-signer/socket```

It will prompt for the password that was set during passphrase that was set during **Step 1 of the Create Wallet for Baker** section.

**Step 3**:

Go back to the first Terminal and import the keys into the tezos-client. (Replace tz1... with the baker address.)

```tezos-client import secret key inacta_baker unix:/home/tezos/.tezos-signer/socket?pkh=<your_baker_address>```

If this would fail try the same command again by force adding -f at the end.

When successful a message will display *Tezos address added: <your_baker_address>*

**Step 4**:

Start the Baker.

```tezos-baker-alpha run with local node /var/run/tezos/node <your_baker_alias>```

**Step 5**:

Start the Endorser.

```tezos-endorser-alpha run <your_baker_alias>```

## Sources
* https://tezos.gitlab.io
* https://github.com/midl-dev/tezos-on-gke
* https://github.com/blockchain-etl/tezos-kubernetes
* https://github.com/tezos-reward-distributor-organization/tezos-reward-distributor
* https://github.com/serokell/tezos-packaging
* https://snapshots-tezos.giganode.io

