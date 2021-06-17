# Topology Graph Generator for Operator Managed Deployments

[hco_topo.sh](hco_topo.sh) Main script to query in a namespace and generate a [DOT](https://graphviz.org/doc/info/lang.html) file.

## Prerequisites

  - OpenShift (or kubectl) CLI configured for cluster access
  - Graphviz

## Usage

    ./hco_topo.sh | dot -Tpng -o topo.png
