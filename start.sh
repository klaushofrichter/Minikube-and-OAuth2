#!/bin/bash
set -e

export PUBLICURL="your.domain.com"
export EMAIL="your-email@emailprovider.com" # for cert-manager (optional)
source config.sh  # configure secrets in config.sh. Note that .gitignore includes config.sh

# See details here: https://medium.com/@klaushofrichter/minikube-and-oauth2-a2a383f4d531

# no need to change anything below #
export KUBECONFIG="`pwd`/kubectl.config"
export NAMESPACE="my-app"
export CLUSTER="my-cluster"
export MAC="2221d707e6c1"
export host="\$host" # this is to keep the variable in the ingress yaml after envsubst 
export escaped_request_uri="\$escaped_request_uri"  # as above

[ "${PUBLICURL}" = "your.domain.com" ] && echo "Please change PUBLICURL in $0" && exit 1
[ "${EMAIL}" = "your-email@emailprovider.com" ] && echo "Please change EMAIL in $0" && exit 1
[ "${OAUTH2_PROXY_CLIENT_ID}" = "your-client-id" ] && echo "Please define OAUTH2_PROXY_CLIENT_ID in config.sh" && exit 1
[ "${OAUTH2_PROXY_CLIENT_SECRET}" = "your-client-secret" ] && echo "Please define OAUTH2_PROXY_CLIENT_SECRET in config.sh" && exit 1
[ "${OAUTH2_PROXY_COOKIE_SECRET}" = "your-cookie-secret" ] && echo "Please define OAUTH2_PROXY_COOKIE_SECRET in config.sh" && exit 1
[ ! -f "prod-${PUBLICURL}-cert.yaml" ] && echo "A suitable certificate for ${PUBLICURL} in \"prod-${PUBLICURL}-cert.yaml\" is needed." && exit 1

minikube -p ${CLUSTER} delete || true  # providing a clean start
minikube -p ${CLUSTER} --driver=virtualbox start

VBoxManage controlvm ${CLUSTER} poweroff
nic=$( VBoxManage showvminfo ${CLUSTER} --machinereadable | grep ^nic | grep '"none"' | head -n1 | cut -d= -f1 | cut -c4- )
interface=$(ip route | grep default | awk '{ print $5 }')
opts="--macaddress${nic} ${MAC}"
VBoxManage modifyvm ${CLUSTER} --nic${nic} bridged --bridgeadapter${nic} ${interface} ${opts}
minikube -p ${CLUSTER} start
VBIP=$(minikube ssh -p ${CLUSTER} -- ip addr show eth2 | grep inet | awk '{ print $2 }' | cut -d/ -f1)
echo "virtualbox exposed LAN ip is ${VBIP}"
minikube -p ${CLUSTER} addons enable ingress
kubectl delete validatingwebhookconfigurations ingress-nginx-admission  # otherwise some ingresses won't install

kubectl create namespace ${NAMESPACE}
kubectl apply -f prod-${PUBLICURL}-cert.yaml # a certificate backup from https://klaushofrichter.medium.com/minikube-and-lets-encrypt-6e407aabb8ac
cat hello.yaml.template | envsubst | kubectl create --save-config -f -
cat welcome.yaml.template | envsubst | kubectl create --save-config -f -
cat oauth2-proxy.yaml.template | envsubst | kubectl create --save-config -f -
cat secure-ingress.yaml.template | envsubst | kubectl apply -f -

sleep 60 # wait for the cluster to settle

# optional - this may handle certification renewals
#kubectl create -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml --save-config
#cat prod-clusterissuer.yaml.template | envsubst | kubectl apply -f -
#sleep 300  # wait for certmanager pods to launch and possibly renew an expired certificate (no backup is performed here)

echo ""
echo "Done... open the browser to test: https://${PUBLICURL}/hello or https://${PUBLICURL}/welcome"
echo "for kubectl use: \"export KUBECONFIG=${KUBECONFIG}\"  Namespace is \"${NAMESPACE}\""
