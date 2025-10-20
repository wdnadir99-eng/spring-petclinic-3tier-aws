# Section 6: NAT Gateway and Internet Access for Private EC2

In a multi-tier architecture, the private EC2 cannot access the internet directly because it is in a private subnet. However, we need it to:

Install packages (apt-get update, Maven, Git).

Pull source code from GitHub.

Download dependencies for Spring Boot.

The solution is a NAT Gateway, which allows outbound traffic from private instances while keeping them unreachable from the internet.



6.1 Create an Elastic IP (EIP)

A NAT Gateway requires an Elastic IP to provide a public IP for outbound connections.

Go to VPC → Elastic IPs → Allocate Elastic IP address.

Allocate the IP in your region (me-central-1).

Note down the EIP for NAT Gateway creation.



6.2 Create a NAT Gateway

Go to VPC → NAT Gateways → Create NAT Gateway.

Name: PrivateSubnet-NAT-GW.

Subnet: Choose Public Subnet (must be public so NAT has internet access).

Elastic IP: Select the one created in step 6.1.

Click Create NAT Gateway.



6.3 Update the Route Table for the Private Subnet

To send private subnet traffic through NAT Gateway:

Go to VPC → Route Tables → Private Subnet Route Table.

Select Routes → Edit routes → Add route:

Destination: 0.0.0.0/0

Target: nat-xxxxxxxx (your NAT Gateway ID)

Save changes.

Now all outbound internet traffic from the private subnet goes through the NAT Gateway.



6.4 Verify Private EC2 Internet Access

SSH into the private EC2 and run:

ping -c 4 google.com

or

sudo apt-get update

If it succeeds: 

NAT Gateway is configured correctly.

Private EC2 can download packages and pull code.



6.5 Security Group Considerations

Private EC2 SG:

Allow inbound traffic only from ALB SG (port 8080).

Outbound: Allow all (0.0.0.0/0) to use NAT Gateway.

NAT Gateway: No SG required (managed by AWS).



6.6 Testing Application Dependencies

After NAT Gateway setup, you can:

Install Maven and JDK (if not installed):

sudo apt-get update

sudo apt-get install openjdk-17-jdk maven -y

Clone PetClinic repository:

sudo git clone https://github.com/spring-projects/spring-petclinic.git /opt/spring-petclinic

Build the app:

cd /opt/spring-petclinic

sudo mvn package

cd target

sudo java -jar spring-petclinic-3.5.0-SNAPSHOT.jar

Verify the private EC2 serves PetClinic on port 8080 (health check for ALB).





