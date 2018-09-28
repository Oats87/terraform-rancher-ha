#!/bin/sh

terraform init

terraform plan -out=plan.tfout

read -p "Please enter y to accept the plan and apply: " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]; then

	terraform apply plan.tfout

	if [ $? -eq 0 ]; then

		terraform output clusteryml > cluster.yml
		echo "Sleeping for 3 minutes in order to allow docker 17.03 to be installed"
		sleep 180
		rke up
		export KUBECONFIG=$(pwd)/kube_config_cluster.yml
		
		echo "Congratulations, you now have an RKE-created cluster in AWS. To install Rancher, please follow"
		echo "https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-init/"

	else

		echo "An issue occurred trying to apply the terraform plan file. Please check the issue and try again."

	fi

fi

rm plan.tfout
