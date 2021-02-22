#!/bin/bash

NS=openshift-cnv
OC=${OC:-oc}
nsget="$OC get -n $NS"

OPERATORS=$(${nsget} deployments -l olm.owner -o jsonpath='{range.items[*]}{"\""}{@.metadata.name}{"\" "}{end}')
operators() {
${nsget} deployments -l olm.owner \
  -o jsonpath='{range .items[*]}{"\""}{@.metadata.name}{"\" -> \""}{@.metadata.labels.olm\.owner}{"\" [color=\"#0077BB\"]\n"}{end}'
}

CONTROLLERS=$(${nsget} deployments -l \!olm.owner -o jsonpath='{range.items[*]}{"\""}{@.metadata.name}{"\" "}{end}'${JSON_LIST})
controllers() {
${nsget} deployments -l \!olm.owner \
  -o jsonpath='{range .items[*]}{"\""}{@.metadata.name}{"\" -> \""}{@.metadata.managedFields[0].manager}{"\" [color=\"#009988\"]\n"}{end}'
}

AGENTS=$(${nsget} daemonsets -o jsonpath='{range.items[*]}{"\""}{@.metadata.name}{"\" "}{end}'${JSON_LIST})
nodeagents() {
${nsget} daemonsets \
  -o jsonpath='{range .items[*]}{"\""}{@.metadata.name}{"\" -> \""}{@.metadata.managedFields[0].manager}{"\" [color=\"#EE7733\"]\n"}{end}'
}

cat <<EOG

digraph G
{
node [shape=record];

{ rank=same ${OPERATORS} }
{ rank=same ${CONTROLLERS} }
{ rank=same ${AGENTS} }

`operators`

`controllers`

`nodeagents`

}

EOG
