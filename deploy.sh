#! /bin/bash

# exit on first command that fails
set -e

sep="-----------------------------------------------------------------------------------------------------------------------------------------------------"
# First we will need an external static ip address
# You can change the name of the ip address from vpn-address to any other name
echo $sep
echo "Listing existence of external IP ADDRESSES"
IP_ADDRESS=$(gcloud compute addresses list --project ${PROJECT_ID} --filter="region:( ${REGION} )" --limit=1 | grep "vpn-address" | cut -d ' ' -f3)
if [ -z $IP_ADDRESS ]
then
    echo "THERE'S NO ADDRESSES...CREATING A NEW ONE"
    echo $sep
    echo "Creating external IP ADDRESS"
    gcloud compute addresses create vpn-address --region=${REGION}
    
    # We need to store the value of this IP Address created
    IP_ADDRESS=$(gcloud compute addresses list | grep "vpn-address" | cut -d ' ' -f3)
else
    echo "USING EXISTING ADDRESS $IP_ADDRESS"
fi

echo "IP_ADDRESS: $IP_ADDRESS"

# Creating copy of old template
cp vpn-vm.yaml /tmp/vpn-vm.yaml

# Substitute this IP and zone in deployment manager template
sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" vpn-vm.yaml
sed -i "s/ZONE/${ZONE}/g" vpn-vm.yaml
sed -i "s/PROJECT_ID/${PROJECT_ID}/g" vpn-vm.yaml
sed -i "s/USERNAME/${USERNAME}/g" vpn-vm.yaml

# Deploy the deployment )
echo $sep
echo "Creating deployment in deployment-manager"
gcloud deployment-manager deployments create vpn-vm --config vpn-vm.yaml

echo "Sleeping 10 minute on purpose..."
sleep 10m

ssh-keygen -f "$HOME/.ssh/known_hosts" -R $IP_ADDRESS

# Fetch the necessaries configuration files
echo $sep
echo "Exporting default vpnclient configuration"
ssh -o "StrictHostKeyChecking no" ${USERNAME}@$IP_ADDRESS 'cd /home/${USERNAME} && sudo ikev2.sh --exportclient vpnclient'
scp ./rc.local ${USERNAME}@$IP_ADDRESS:/etc/

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

# going back in path
cd ../

echo $sep
echo "Restauring value of old template"
mv /tmp/vpn-vm.yaml vpn-vm.yaml

echo $sep
echo "DONE"
