# terraform-rancher-ha

## About

This is a set of scripts designed to allow you to install Rancher HA in AWS. These are rudimentary at best, and I assume no responsibility to any charges incurred by these scripts or any problems you may encounter through the use of them.

There are two sets of scripts provided, `spot` and `on-demand`. The `spot` terraform scripts will create spot requests; while these spot instances are cheaper, they are definitely not reliable and could cause issues if you try to run actual workloads on your instances. `on-demand` will create instances on-demand, and will thus cost more but provide a more reliable Rancher HA install.