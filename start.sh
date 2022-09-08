#! /bin/bash


sep="-----------------------------------------------------------------------------------------------------------------------------------------------------"

echo $sep
echo "Listing existence of external IP ADDRESSES"
IP_ADDRESS=$(gcloud compute addresses list --project ${PROJECT_ID} --filter="region:( ${REGION} )" --limit=1 | grep "vpn-address" | cut -d ' ' -f3)

echo "IP_ADDRESS: $IP_ADDRESS"

gcloud compute instances start vpn-vm --zone=${ZONE}
echo "Sleeping 10 minutes on purpose"
sleep 1m

ssh-keygen -f "$HOME/.ssh/known_hosts" -R $IP_ADDRESS

# Fetch the necessaries configuration files
echo $sep
echo "Exporting default vpnclient configuration"
ssh -o "StrictHostKeyChecking no" ${USERNAME}@$IP_ADDRESS 'cd /home/${USERNAME} && sudo ikev2.sh --exportclient vpnclient'

echo $sep
echo "Copying files from remote vm into certs folder"
mkdir -p certs
scp ${USERNAME}@$IP_ADDRESS:/home/${USERNAME}/* ./certs

echo $sep
echo "Changing path position"
cd certs

# extracting certs from configuration file for Ubuntu
echo $sep
echo "Press enter on import password, or the password specified in the previous logs. By default you just need to press <ENTER>"
openssl pkcs12 -in vpnclient.p12 -cacerts -nokeys -out ikev2vpnca.cer
openssl pkcs12 -in vpnclient.p12 -clcerts -nokeys -out vpnclient.cer
openssl pkcs12 -in vpnclient.p12 -nocerts -nodes  -out vpnclient.key

echo $sep
echo "DONE"
