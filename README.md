# mbentley/audit-cluster

docker image for auditing a Swarm/UCP cluster to return the core counts and other sizing stats
based off of alpine:latest

To pull this image:
`docker pull mbentley/audit cluster`

Example usage:

```
docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock -e affinity:container==ucp-controller mbentley/audit-cluster
```
