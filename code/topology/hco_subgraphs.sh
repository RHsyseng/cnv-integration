#!/bin/bash
# usage: cat topo.sh | ssh node01 bash  | tee /dev/stderr  | osage -Tpng -o noname.gv.png

NS=openshift-cnv
OC=${OC:-oc}
nsget() { $OC get -n $NS $@ ; }

operators() {
nsget deployments -l olm.owner --no-headers -o custom-columns=name:.metadata.name,count:.spec.replicas
}

controllers() {
nsget deployments -l \!olm.owner --no-headers -o custom-columns=name:.metadata.name,count:.spec.replicas
}

nodeagents() {
nsget daemonsets --no-headers -o custom-columns=name:.metadata.name,count:.status.desiredNumberScheduled
}

toNode() {
sed "s/\(^[a-z0-9-]\+\)\s\+\(.\)/\"\1 count=\2\"/ ; s/-/_/g"
}

cat <<EOG

digraph G
{

subgraph cluster_0 {
label="operators (fixed)"
color=blue
`operators | toNode`
}

subgraph cluster_1 {
label="controllers (fixed)"
`controllers | toNode`
}

subgraph cluster_2 {
label="nodeagents (node count)"
`nodeagents | toNode`
}

}

EOG