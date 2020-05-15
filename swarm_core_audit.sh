#!/bin/bash

set -e

# set curl command to be able to re-use it and help readability of the script
CURL_CMD="curl -s -m 5 --unix-socket /var/run/docker.sock http://v1.30"

# check to see if the docker socket is available
if [ ! -S /var/run/docker.sock ]
then
  echo "ERROR: Docker socket not found at /var/run/docker.sock"
  exit 1
fi

# shellcheck disable=SC2086
# check to see if the engine is Swarm/is a manager by trying to get a token
if [ "$(${CURL_CMD}/swarm | jq -r .message)" != "null" ]
then
  echo "ERROR: Docker engine is not a Swarm manager"
  exit 1
fi

pull_node_data() {
  # output for type
  echo -e "Data for ${1} nodes:"

  # add filter for managers or workers
  if [ "${1}" = "manager" ] || [ "${1}" = "worker" ]
  then
    NODE_FILTER="?filters=%7B%22role%22%3A%7B%22${1}%22%3Atrue%7D%7D"
  fi

  # shellcheck disable=SC2086
  # get the number of nano CPUs reported from Swarm on each node
  nanoCPUs="$(for NODE in $(${CURL_CMD}/nodes${NODE_FILTER} | jq -r '.[]|.ID'); do ${CURL_CMD}/nodes/"${NODE}" | jq -r .Description.Resources.NanoCPUs; done)"

  # convery nano CPUs to CPUs
  CPUs=$(for i in ${nanoCPUs}; do   echo "$((i/1000000000))"; done)

  # get the sum of all CPU counts
  ttlCPU="$(COUNT=0; TOTAL=0; for i in ${CPUs};do TOTAL=$(echo "${TOTAL}+${i}" | bc ); ((COUNT++)); done; echo "${TOTAL}")"

  # count the number of nodes reported
  NODE_COUNT=$(echo "${CPUs}" | wc -l)

  # find the average CPU count
  avgCPU="$(echo "scale=2; ${ttlCPU} / ${NODE_COUNT}" | bc)"

  # determine the smallest # CPUs per node
  minCPU="$(echo "${CPUs}" | sort -n | head -1)"

  # determine the largest # CPUs per node
  maxCPU="$(echo "${CPUs}" | sort -n | tail -n 1)"

  # find the unique CPU node sizes
  CPU_sizes="$(echo "${CPUs}" | sort -n | uniq)"

  # report the quantity of nodes that match a given number of CPUs
  for SIZE in ${CPU_sizes}; do echo -n "${SIZE} Core x "; echo "${CPUs}" | grep "${SIZE}" | sort -n | wc -l; done

  # report the rest of the data
  echo "
# Nodes - ${NODE_COUNT}
Ttl Core - ${ttlCPU}
Min Core - ${minCPU}
Max Core - ${maxCPU}
Avg Core - ${avgCPU}"
}

echo "========================"
pull_node_data all
echo "========================"
pull_node_data manager
echo "========================"
pull_node_data worker
echo "========================"
