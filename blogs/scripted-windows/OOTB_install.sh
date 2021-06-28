#!/usr/bin/env bash

OCFILE="./oc-creds.yaml"
YAMLFILE="."

# Check if the bak file exists and exit the script
# in order to make sure that nothing is overwritten

if [ -f "$OCFILE.bak" ]; then
	echo "config file exists in $OCFILE.bak"
        exit 1
fi


# Sets the connection to the OpenShift cluster
echo "Please enter OpenShift login details:"

echo "OpenShift API:"
read OCAPI

echo "OpenShift Username:"
read OCUSER

echo "OpenShift Pass:"
read OCPASS

# Encode the values to fit the yaml 
API=$(echo "$OCAPI" | base64)
USER=$(echo "$OCUSER" | base64)
PASS=$(echo "$OCPASS" | base64)

sed -i.bak "s/<base64 URL>/$API/" $OCFILE
sed -i "s/<base64 user>/$USER/" $OCFILE
sed -i "s/<base64 password>/$PASS/" $OCFILE

kubectl apply -f $YAMLFILE/install-windows-configmap.yaml
kubectl apply -f $YAMLFILE/win-installation-scripts.yaml
kubectl apply -f $YAMLFILE/windows-install-pod.yaml