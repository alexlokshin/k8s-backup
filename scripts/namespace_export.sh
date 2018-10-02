#!/bin/bash

set -eo pipefail

die(){
    echo "$1"
    exit "$2"
}

usage(){
    echo "$0 <namespace>"
    echo "  namespace  The name of the Kubernetes namespace to be exported."
    echo "Examples:"
    echo "  $0 mynamespace"
    echo "Env variables:"
    echo "  BACKUP_SECRETS (default true) if secrets should be backed up."
}

exportlist(){
    if [ "$#" -lt "3" ]; then
        echo "Invalid parameters"
        return
    fi

    KIND=$1
    BASENAME=$2
    DELETEPARAM=$3

    echo "Exporting '${KIND}' resources to ${NAMESPACE}/${BASENAME}.json"

    BUFFER=$(kubectl get "${KIND}" --export -o json -n "${NAMESPACE}" || true)

    # return if resource type unknown or access denied
    if [ -z "${BUFFER}" ]; then
        echo "Skipped: no data"
        return
    fi

    # return if list empty
    if [ "$(echo "${BUFFER}" | jq '.items | length > 0')" == "false" ]; then
        echo "Skipped: list empty"
        return
    fi

    echo "${BUFFER}" | jq "${DELETEPARAM}" > "${NAMESPACE}/${BASENAME}.json"
}

ns(){
    exportlist \
        ns \
        ns \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

rolebindings(){
    exportlist \
        rolebindings \
        rolebindings \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

serviceaccounts(){
    exportlist \
        serviceaccounts \
        serviceaccounts \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

secrets(){
    exportlist \
        secrets \
        secrets \
        'del('\
'.items[]|select(.type=='\
'"'\
'kubernetes.io/service-account-token'\
'"'\
'))|'\
'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.annotations.'\
'"'\
'kubernetes.io/service-account.uid'\
'"'\
')'
}

bcs(){
    exportlist \
        bc \
        bcs \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.generation,'\
'.items[].spec.triggers[].imageChangeParams.lastTriggeredImage)'
}

ingress(){
    exportlist \
        ingress \
        ingress \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.generation)'
}

builds(){
    exportlist \
        builds \
        builds \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

is(){
    exportlist \
        is \
        iss \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

rcs(){
    exportlist \
        rc \
        rcs \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

svcs(){
    echo "Exporting services to ${NAMESPACE}/svc_*.json"
    SVCS=$(kubectl get svc -n "${NAMESPACE}" -o jsonpath="{.items[*].metadata.name}")
    for svc in ${SVCS}; do
        kubectl get --export -o=json svc "${svc}" -n "${NAMESPACE}" | jq '
      del(.status,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation,
            .spec.clusterIP
        )' > "${NAMESPACE}/svc_${svc}.json"
        if [[ $(jq -e '.spec.selector.app' "${NAMESPACE}/svc_${svc}.json") == "null" ]]; then
            kubectl get --export -o json endpoints "${svc}" -n "${NAMESPACE}" | jq '
        del(.status,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation
            )' > "${NAMESPACE}/endpoint_${svc}.json"
        fi
    done
}

pods(){
    exportlist \
        po \
        pods \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

cms(){
    exportlist \
        cm \
        cms \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

pvcs(){
    exportlist \
        pvc \
        pvcs \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].metadata.annotations['\
'"'\
'pv.kubernetes.io/bind-completed'\
'"'\
'],'\
'.items[].metadata.annotations['\
'"'\
'pv.kubernetes.io/bound-by-controller'\
'"'\
'],'\
'.items[].metadata.annotations['\
'"'\
'volume.beta.kubernetes.io/storage-provisioner'\
'"'\
'],'\
'.items[].spec.volumeName)'
}

pvcs_attachment(){
    exportlist \
        pvc \
        pvcs_attachment \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

routes(){
    exportlist \
        routes \
        routes \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

templates(){
    exportlist \
        templates \
        templates \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

egressnetworkpolicies(){
    exportlist \
        egressnetworkpolicies \
        egressnetworkpolicies \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

imagestreamtags(){
    exportlist \
        imagestreamtags \
        imagestreamtags \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].tag.generation)'
}

rolebindingrestrictions(){
    exportlist \
        rolebindingrestrictions \
        rolebindingrestrictions \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

limitranges(){
    exportlist \
        limitranges \
        limitranges \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

resourcequotas(){
    exportlist \
        resourcequotas \
        resourcequotas \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].status)'
}

podpreset(){
    exportlist \
        podpreset \
        podpreset \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

cronjobs(){
    exportlist \
        cronjobs \
        cronjobs \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].status)'
}

statefulsets(){
    exportlist \
        statefulsets \
        statefulsets \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].status)'
}

hpas(){
    exportlist \
        hpa \
        hpas \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].status)'
}

deployments(){
    exportlist \
        deploy \
        deployments \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].status)'
}

replicasets(){
    exportlist \
        replicasets \
        replicasets \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].status,'\
'.items[].ownerReferences.uid)'
}

poddisruptionbudget(){
    exportlist \
        poddisruptionbudget \
        poddisruptionbudget \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].status)'
}

daemonset(){
    exportlist \
        daemonset \
        daemonset \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].status)'
}

BACKUP_SECRETS="${BACKUP_SECRETS:-true}"

if [[ ( $* == "--help") ||  $* == "-h" ]]; then
    usage
    exit 0
fi

if [[ $# -lt 1 ]]; then
    usage
    die "projectname not provided" 2
fi

for i in jq kubectl; do
    command -v $i >/dev/null 2>&1 || die "$i required but not found" 3
done

NAMESPACE="${1}"

mkdir -p "${NAMESPACE}"

ns
rolebindings
serviceaccounts
if ${BACKUP_SECRETS}; then
    secrets
fi
rcs
svcs
pods
podpreset
cms
egressnetworkpolicies
ingress
rolebindingrestrictions
limitranges
resourcequotas
pvcs
pvcs_attachment
cronjobs
statefulsets
hpas
deployments
replicasets
poddisruptionbudget
daemonset

exit 0
