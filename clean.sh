#! /bin/bash

gcloud compute addresses delete vpn-address --region=${REGION}
gcloud deployment-manager deployments delete vpn-vm
