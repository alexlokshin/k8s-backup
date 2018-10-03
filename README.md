# Kubernetes namespace backup

![Docker Automated](https://img.shields.io/docker/automated/gerald1248/k8s-backup.svg)
![Docker Build](https://img.shields.io/docker/build/gerald1248/k8s-backup.svg)

![Overview of k8s-backup](ditaa/backup-restore.png)

## Getting started 
```
$ git clone https://github.com/gerald1248/k8s-backup
$ make install -C k8s-backup/
helm install --name=k8s-backup .
NAME:   k8s-backup
LAST DEPLOYED: Wed Oct  3 20:06:58 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod(related)
NAME                         READY  STATUS             RESTARTS  AGE
k8s-backup-5c867c98d4-ckbxq  0/1    ContainerCreating  0         0s

==> v1/PersistentVolumeClaim

NAME        AGE
k8s-backup  0s

==> v1/ServiceAccount
k8s-backup  0s

==> v1/ClusterRole
custom-reader  0s

==> v1/ClusterRoleBinding
k8s-backup                0s
k8s-backup-secret-reader  0s

==> v1/Deployment
k8s-backup  0s

==> v1beta1/CronJob
k8s-backup  0s
```

This project sets up a CronJob running a basic namespace backup script `namespace-export` (based on `project_export.sh` on [GitHub](https://raw.githubusercontent.com/gerald1248/k8s-ansible-contrib/refactor_export/reference-architecture/day2ops/scripts/project_export.sh).

Please note that no attempt is made to back up the contents of databases or mounted persistent volumes. This backup focuses on the API objects stored in `etcd`.

Admin access is required at the start (to create project and the `cluster-reader` and `secret-reader` ClusterRoleBindings for the service account), but from then on access is strictly controlled.

**NOTE** `secret-reader` is only needed if you intend to backup secrets and omitted by default. To activate backups of your secrets, adjust `values.yaml` or pass `set backup-secrets=true` to `helm`.

![Permissions](ditaa/permissions.png)

## Environment variables

| Name                         | Default            | Description                                                                    |
| ---------------------------- | ------------------ | ------------------------------------------------------------------------------ |
| `BACKUP_SECRETS`             | `false`             | If Secrets should also be backed up.                                           |
| `K8S_BACKUP_NAME`      | `k8s-backup` | Name of each API object                                                        |
| `K8S_BACKUP_CAPACITY`  | `2Gi`              | Create a PersistentVolumeClaim with this size and use it to store the backups. |
| `K8S_BACKUP_SCHEDULE`  | `15 0 * * *`       | The schedule at which the backup CronJob will be run.                          |

## Set the timer
```
$ make
```

## Build your own Docker image
You can skip this step if you're happy to use the Docker Hub image that accompanies this repo (`gerald1248/k8s-backup`).

```
$ make build
```

The current version is built from this repo.

## Cleanup
Call `make delete` to remove the objects installed.

## Run the tests
```
$ make test
```
This will build the image and check the installed tools are present.
