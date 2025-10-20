# Section 2: Architecture Design – VPC, Subnets, Routing, and Core Networking

To securely deploy the three-tier application, we first built a custom Virtual Private Cloud (VPC). This is the foundation of the project because all other resources (EC2, RDS, Load Balancer, NAT Gateway) depend on the network design.



2.1 VPC Creation

A custom VPC was created instead of using the default one.

CIDR block chosen:

10.0.0.0/16

This provides up to 65,536 private IPs, enough to carve into multiple subnets across AZs.

Command (AWS CLI example):

aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region me-central-1



2.2 Subnet Design

We divided the VPC into public and private subnets across two Availability Zones (AZs) for high availability.

Public Subnets

Subnet A: 10.0.1.0/24 (AZ1)

Subnet B: 10.0.2.0/24 (AZ2)

Hosts: Load Balancer + NAT Gateway + Bastion/Test EC2



Private Subnets (App Layer)

Subnet C: 10.0.3.0/24 (AZ1)

Subnet D: 10.0.4.0/24 (AZ2)

Hosts: Application EC2 (Spring PetClinic)



Private Subnets (DB Layer)

Subnet E: 10.0.5.0/24 (AZ1)

Subnet F: 10.0.6.0/24 (AZ2)

Hosts: Amazon RDS (MySQL)

This way, even if one AZ fails, traffic automatically shifts to the other.





2.3 Internet Gateway (IGW)

An Internet Gateway was attached to the VPC to enable internet connectivity for public subnets.

Without this, EC2s in public subnets wouldn’t be reachable from outside.

Command:

aws ec2 create-internet-gateway

aws ec2 attach-internet-gateway --vpc-id vpc-xxxx --internet-gateway-id igw-xxxx





2.4 NAT Gateway

Private EC2 instances (like the app server) need internet access to:

Install system updates.

Download dependencies (Maven, Java packages).

A NAT Gateway was created in each public subnet, one per AZ.

Elastic IPs were attached to NAT Gateways.

Routing rule:

Private subnets route outbound traffic to NAT Gateway → NAT forwards to Internet Gateway → internet.



2.5 Route Tables

We set up different route tables for public and private subnets:

Public Route Table:

Route to Internet Gateway (IGW) for 0.0.0.0/0.

Associated with Public Subnets A & B.



Private App Route Table:

Route to NAT Gateway for 0.0.0.0/0.

Associated with Subnets C & D (Application Tier).



Private DB Route Table:

No internet access.

Only internal communication within VPC.

Associated with Subnets E & F (Database Tier).







2.6 Security Groups

Security groups act like firewalls at the instance level.

Web ec2 SG

Inbound: Allow HTTP (80), HTTPS (443) from anywhere, SSH from my IP

Outbound: Allow all traffic to App EC2 SG.









Load Balancer SG

Inbound: Allow HTTP (80), HTTPS (443) from anywhere.

Outbound: Allow all traffic to App EC2 SG.



App EC2 SG

Inbound: Allow HTTP (8080) only from Load Balancer SG.

Outbound: Allow MySQL (3306) to DB SG.



Database SG

Inbound: Allow MySQL (3306) only from App EC2 SG.

Outbound: Restricted to internal VPC traffic.



2.7 Network Flow Recap

User → Browser → ALB (Public Subnet)

ALB → forwards traffic → App EC2 (Private Subnet)

App EC2 → queries → RDS MySQL (Private DB Subnet)

Responses flow back through the same path.

This ensures:

No direct access to app or DB from the internet.

Only the ALB is exposed publicly.

Least privilege principle is enforced at every level.













