# HA VPN with Transit Gateway
Provisions the necessary resources to establish network connectivity between GCP and AWS. The AWS side of the connection uses Transit Gateway (TGW). Choose HA VPN with TGW if you wish to establish connectivity between multiple VPCs in AWS and your network in GCP.

Terraform apply order:
1. 00_gcp_vpn_gateway
2. 01_aws_vpn_components
3. 02_gcp_vpn_components