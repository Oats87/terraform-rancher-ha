#!/bin/sh

terraform destroy -auto-approve

if [ $? -eq 0 ]; then

	rm -f cluster.yml
	rm -f kube_config_cluster.yml

	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup

	rm -rf .terraform

fi
