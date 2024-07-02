#!/usr/bin/env sh
#
# SPDX-License-Identifier: Apache-2.0
#
set -eu

#
# Install Galasa Ecosystem (WIP!)
#

# Make sure minikube has started
until minikube status; do
    sleep 5
done

# Need DNS for ingress
# TODO grep for the minikube IP before adding it again
minikube addons enable ingress
minikube addons enable ingress-dns
echo "nameserver $(minikube ip)" | sudo tee -a /etc/resolv.conf

helm repo add galasa https://galasa-dev.github.io/helm

curl -sSL https://raw.githubusercontent.com/galasa-dev/helm/ecosystem-0.35.0/charts/ecosystem/values.yaml \
  | yq '.storageClass = "standard" | .externalHostname = "galasa.test" | .dex.config.issuer = "http://galasa.test/dex"' \
  | helm install -f - galasa galasa/ecosystem --wait

# Just incase it all goes horribly wrong...
# minikube delete --all --purge
