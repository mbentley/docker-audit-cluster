# mbentley/audit-cluster

docker image for auditing a Swarm/UCP cluster to return the core counts and other sizing stats
based off of alpine:latest

To pull this image:
`docker pull mbentley/audit-cluster`

Example usage:

1. Load a UCP client bundle (or skip the client bundle and run the command directly on a manager)

1. Run the container:

    ```
    docker run -t --rm --name audit-cluster \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -e affinity:container==ucp-controller \
      mbentley/audit-cluster
    ```

1. Results will be returned:

    ```
    $ docker run -t --rm --name audit-cluster \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e affinity:container==ucp-controller \
        mbentley/audit-cluster
    2 Core x 4
    4 Core x 11

    # Nodes - 15
    Ttl Core - 52
    Min Core - 2
    Max Core - 4
    Avg Core - 3.46
    ```

   In the above example, the cluster has 15 nodes, 4 nodes have 2 cores each, 11 nodes have 4 cores each.
