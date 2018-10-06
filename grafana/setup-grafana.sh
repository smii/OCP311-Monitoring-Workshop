#!/bin/bash

datasource_name=''
prometheus_namespace=''
sa_reader=''
graph_granularity=''
yaml=''
protocol="https://"

while getopts 'n:s:p:g:y:ae' flag; do
  case "${flag}" in
    n) datasource_name="${OPTARG}" ;;
    s) sa_reader="${OPTARG}" ;;
    p) prometheus_namespace="${OPTARG}" ;;
    g) graph_granularity="${OPTARG}" ;;
    y) yaml="${OPTARG}" ;;
    a) setoauth=1 ;;
    e) node_exporter=1;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

usage() {
echo "
USAGE
 setup-grafana.sh -n <datasource_name> -a [optional: -p <prometheus_namespace> -s <prometheus_serviceaccount> -g <graph_granularity> -y <yaml> -e]

 switches:
   -n: grafana datasource name
   -s: prometheus serviceaccount name
   -p: existing prometheus name e.g openshift-metrics
   -g: specifiy granularity
   -y: specifies the grafana yaml
   -a: deploy oauth proxy for grafana - otherwise skip it (for preconfigured deployment)
   -e: deploy node exporter

 note:
    - the project must have view permissions for kube-system
    - the script allow to use high granularity by adding '30s' arg, but it needs tuned scrape prometheus
"
exit 1
}

# deploy openshift dashboard
dashboard_file="./openshift-cluster-monitoring.json"
sed -i.bak "s/Xs/${graph_granularity}/" "${dashboard_file}"
sed -i.bak "s/\${DS_PR}/${datasource_name}/" "${dashboard_file}"
#curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@${dashboard_file}"
mv "${dashboard_file}.bak" "${dashboard_file}"


exit 0
