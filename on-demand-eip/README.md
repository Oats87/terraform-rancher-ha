# terraform-rancher-ha/on-demand-eip

## On-Demand Instance Terraform

This will create on-demand instances in EC2 for consumption. This is generally going to be more reliable as spot instances can be terminated at any time. This attaches EIP's to the instances which allows you to shut down your instances when you are not using them and boot them to recover your state. Do keep in mind that you will receive charges for the EIP and EBS volume storage during the time your instances are off.

## WARNING

This Terraform Script is rudimentary at best, and will create resources in AWS that will incur charges. You are running this Terraform script at your own risk, I am not responsible for any charges that occur due to the usage of these scripts.

It is your responsibility to inspect the terraform plan to ensure that the resources being created are acceptable by you.

## Information

This is a quick and dirty Terraform script that can be used to create an environment ready to `helm` install Rancher 2.0 in HA

This Terraform should get you to the step here: https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-init/

This will create a Route 53 entry like 

`<prefix>-ha.<r53_hosted_zone>` which will look like `myhacluster-ha.my.r53.zone.com` according to the `terraform.tfvars.example`

## Pre-requisites

Make sure you have `rke`, `helm`, and `kubectl` available in your path.

## Installing Rancher

1. Copy `terraform.tfvars.examples` to `terraform.tfvars`

1. Modify `terraform.tfvars` to reflect your desired features

1. Run `source create.sh` to create the AWS resources and RKE up a cluster

1. `kubectl -n kube-system create serviceaccount tiller`

1. `kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller`

1. `helm init --service-account tiller`

1. `helm install stable/cert-manager --name cert-manager --namespace kube-system`

1. `helm repo add rancher-stable https://releases.rancher.com/server-charts/stable`

1. Run the following helm install command with your e-mail and route 53 hostname substituted in:

```
helm install rancher-stable/rancher --name rancher --namespace cattle-system --set hostname=<route53hostname> --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=<your-email>
```

## Automatically installing helm

1. Use the command line switch `-i` with the create.sh script to inform it to execute the helm install. This is required to automatically install via helm and must not be included if you choose to manually install Rancher via helm.

`./create.sh -i`

1. Use the command line switch `-v rancher_version` with the create.sh script to set a specific rancher version. If this is not specified version `v2.1.0` will be used. There is currently no `latest` or `stable` version option for the Rancher helm chart. This only works when the `-i` flag is also used.
`./create.sh -i -v v2.0.8`

1. To also use letsEncrypt certs, use the command line switch -c with an email address parameter. 
`./create.sh -i -v v2.0.8 -c your.email@somewhere.net`

Putting it altogether to have an automated helm install with a specific Rancher version and also using letsEncrypt certs looks like this.
```
./create.sh -i -c your.email@somewhere.net
```

The url for the installation is automatically assembled by parameters specified in terraform.tfvars and configured to use route53.

For all other installation configurations. Alternative certs or other specific arguments that you want to use with the `helm install` command, it is best to run the command(s) by hand following the `Installing Rancher` section.

## Cleaning up

Running `./destroy.sh` will terraform destroy your AWS resources and remove all auxiliary files.