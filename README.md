# Lazy setup of a VPN on GCP

Running this script will setup a VPN on Google Cloud Platform, in order to run this script you will need to set the following environment variables:

```bash
export USERNAME="gcp-username"
export REGION="region"
export ZONE="zone"
export PROJECT_ID="project-id"
```

Change these values with the correct ones.

You will need to create a firewall rule in your gcp console, that allow the traffic on ports 500 and 4500 on TCP and UDP protocols.
To this firewall assign the tag, "vpn".

After that you only need to run:

```bash
sh deploy.sh
```

That's all, you're welcome!.

In case you want to clean up what you created, you could run the `clean.sh` script in the same way, `sh clean.sh`.
