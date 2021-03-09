FROM harbor.beautytiger.com/k8s.gcr.io/etcd:3.4.13-0 as src

FROM harbor.beautytiger.com/docker.io/centos:rich
COPY --from=src /usr/local/bin /usr/local/bin