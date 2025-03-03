# HA VPN with Virtual Private Gateway
Provisions the necessary resources to establish network connectivity between GCP and AWS. The AWS side of the connection uses Virtual Private Gateway (VGW). Select HA VPN with VGW if you wish to create direct connectivity between your GCP network and AWS VPC.

Terraform apply order:
1. 00_gcp_vpn_gateway
2. 01_aws_vpn_components
3. 02_gcp_vpn_components