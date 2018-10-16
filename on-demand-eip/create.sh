#!/bin/bash

RANCHER_VERSION="latest"
HOST_URL=""
HELM_INSTALL=0

while getopts "v:h:i" opt; do
  case $opt in
    v)
      RANCHER_VERSION=$OPTARG
      ;;
    h)
      HOST_URL=$OPTARG
      ;;
    i) 
      HELM_INSTALL=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

terraform init

terraform plan -out=plan.tfout -detailed-exitcode
TERRA_DIFF=$?

read -p "Please enter y to accept the plan and apply: " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]; then

	terraform apply plan.tfout

	if [[ $? -eq 0 ]]; then

		if [[ "$TERRA_DIFF" -ne 0 ]]; then
			terraform output clusteryml > cluster.yml
			echo "Sleeping for 3 minutes in order to allow docker 17.03 to be installed"
			sleep 180
			rke up
			export KUBECONFIG=$(pwd)/kube_config_cluster.yml
		fi
		
		if [ "$HELM_INSTALL" -eq 0 ]; then
			echo "Congratulations, you now have an RKE-created cluster in AWS."
			echo "To install Rancher, please follow the Rancher HA install guide."
			echo "https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-init/"
		else
			if [ -z "$HOST_URL" ]; then
				echo "Host url cannot be empty."
				echo "Use the -h flag with the host url argument. Or run the helm install command manually"
				exit 1;
			fi
			kubectl -n kube-system create serviceaccount tiller
			kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
			helm init --service-account tiller

			echo "Take a 30 second break k8s needs a moment to reconcile ..."
			sleep 30

			helm install stable/cert-manager --name cert-manager --namespace kube-system
			helm install rancher-stable/rancher --name rancher --namespace cattle-system --version $RANCHER_VERSION --set hostname=$HOST_URL 
		fi
	else

		echo "An issue occurred trying to apply the terraform plan file. Please check the issue and try again."

	fi

fi

rm plan.tfout