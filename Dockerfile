FROM ubuntu:18.04
LABEL maintainer="Gerald Schmidt <gerald1248@gmail.com>"
LABEL description="Automated namespace backups"
ENV KUBE_VERSION=v1.12.0

RUN apt-get update && apt-get install -y jq wget zip
RUN wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x /usr/local/bin/kubectl
RUN groupadd app && useradd -g app app && \
  mkdir /app && \
  mkdir /k8s-backup && \
  chown app:app /k8s-backup && \
  chmod 777 /app
ADD bin/namespace-export /usr/bin/
ADD bin/k8s-backup /usr/bin/

RUN chmod +x /usr/bin/namespace-export

WORKDIR /app

USER app

CMD ["/bin/sh", "-c", "while true; do sleep 60; done"]
