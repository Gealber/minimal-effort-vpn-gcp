#! /bin/bash

set -e

gcloud compute instances stop vpn-vm --zone=${ZONE}
