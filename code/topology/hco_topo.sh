#!/bin/bash

NS=openshift-cnv
OC=${OC:-oc}
nsget="$OC get -n $NS"

OP_LIST=$(${nsget} deployments -l olm.owner -o jsonpath='{range.items[*]}{"\""}{@.metadata.name}{"\" "}{end}')
operators() {
${nsget} deployments -l olm.owner \
  -o jsonpath='{range .items[*]}{"\""}{@.metadata.name}{"\" -> \""}{@.metadata.labels.olm\.owner}{"\" [color=\"#0077BB\"];\n"}{end}'
}

CO_LIST=$(${nsget} deployments -l \!olm.owner -o jsonpath='{range.items[*]}{"\""}{@.metadata.name}{"\" "}{end}'${JSON_LIST})
controllers() {
${nsget} deployments -l \!olm.owner \
  -o jsonpath='{range .items[*]}{"\""}{@.metadata.name}{"\" -> \""}{@.metadata.managedFields[0].manager}{"\" [color=\"#009988\"];\n"}{end}'
}

AG_LIST=$(${nsget} daemonsets -o jsonpath='{range.items[*]}{"\""}{@.metadata.name}{"\" "}{end}'${JSON_LIST})
nodeagents() {
${nsget} daemonsets \
  -o jsonpath='{range .items[*]}{"\""}{@.metadata.name}{"\" -> \""}{@.metadata.managedFields[0].manager}{"\" [color=\"#EE7733\"];\n"}{end}'
}

cat <<EOG

digraph G
{
  node [shape=record];
  
  subgraph cluster_legend {
    Operators [shape=oval]
    Controllers [style=rounded]
    "Node Agents"
  }
  subgraph cluster_ops {
    node [shape=oval];
    label = "Operators";
    `operators`
    { rank=same ${OP_LIST} }
  }
  subgraph controllers {
    node [style=rounded]
    `controllers`
    { rank=same ${CO_LIST} }
  }
  subgraph agents {
    `nodeagents`
    { rank=same ${AG_LIST} }
  }
}

EOG
