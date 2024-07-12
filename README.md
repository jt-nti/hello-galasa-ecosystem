# hello-galasa-ecosystem

Just experimenting with installing a Galasa ecosystem!

Unfortunately it turns out that the ecosystem helm charts require amd64, which I don't have, so this likely doesn't work at all.

## Manual instructions

Just trying to do everything manually on an intel based Ubuntu machine since the dev container doesn't work on my machine...

First, start minikube. (This requires a nasty env var which isn't in the Galasa doc because the etcd image won't pull otherwise.)

```
minikube start --docker-env DOCKER_ENABLE_DEPRECATED_PULL_SCHEMA_1_IMAGE=1
```

Setup ingress and sort out dns.

```
minikube addons enable ingress
minikube addons enable ingress-dns
```

Attempt to make galasa.test resolve on the host.

```
mkdir -p /etc/systemd/resolved.conf.d
tee /etc/systemd/resolved.conf.d/minikube.conf << EOF
[Resolve]
DNS=192.168.49.2
Domains=~test
EOF
```

Also, edit /etc/systemd/resolved.conf to add Quad9 DNS. (github.com didn't resolve otherwise!)

Start the fans.

```
systemctl daemon-reload
systemctl restart systemd-resolved
```

See what that did!

```
more /etc/resolv.conf
```

Not entirely that really worked but onward!

Add the galasa helm repo.

```
helm repo add galasa https://galasa-dev.github.io/helm
```

Install the galasa helm chart. The dex config should allow it to start without a GitHub connector. For more information, see https://dexidp.io/docs/connectors/local/

```
curl -sSL https://raw.githubusercontent.com/galasa-dev/helm/ecosystem-0.35.0/charts/ecosystem/values.yaml \
  | yq '
    .storageClass = "standard" |
    .externalHostname = "galasa.test" |
    .dex.config.issuer = "http://galasa.test/dex" |
    .dex.config.enablePasswordDB = true |
    .dex.config.staticPasswords[0].email = "admin@example.com" |
    .dex.config.staticPasswords[0].hash = "$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W" |
    .dex.config.staticPasswords[0].username = "admin" |
    .dex.config.staticPasswords[0].userID = "08a8684b-db88-4b73-90a9-3cd1661f5466"
  ' \
  | helm install -f - galasa galasa/ecosystem --wait
```

Did it blend?

```
kubectl get pods
helm test galasa
```

All good!

Now figure out the bootstrap URL?

```
kubectl get svc
```

Hmmm, no luck!

http://galasa.test/api/bootstrap
http://192.168.49.2/api/bootstrap

To be continued...
