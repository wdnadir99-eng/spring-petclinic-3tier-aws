# Section 3: Provisioning EC2 Instances and Installing Dependencies

The application tier of our project is powered by EC2 instances running inside private subnets. These hosts run the Spring PetClinic application and communicate with the database (RDS).

Since they’re in private subnets, they cannot be accessed directly from the internet. Instead, all management was done via bastion/SSH jump from public subnet or SSM Session Manager.



3.1 Launching the Public EC2 Instances

AMI used: Ubuntu Server 22.04 LTS (free tier eligible).

Instance type: t3.medium (enough CPU & RAM for Maven build and Java app).

Subnet: Public Subnet C (10.0.3.0/24).

Auto-assign Public IP: enabled 

Security Group: web EC2 SG 

Steps in AWS Console:

Go to EC2 → Launch Instance.

Select Ubuntu 22.04 AMI.

Choose t3.medium type.

Place inside public Subnet A.

Enabled Public IP.

Attach the App EC2 Security Group.

Add IAM Role if needed (for SSM access).

Launch the instance.





3.1 Launching the Private EC2 Instances

AMI used: Ubuntu Server 22.04 LTS (free tier eligible).

Instance type: t3.medium (enough CPU & RAM for Maven build and Java app).

Subnet: Private Subnet C (10.0.3.0/24).

Auto-assign Public IP: Disabled (because it’s private).

Security Group: App EC2 SG (only allows traffic from ALB and to DB).

Steps in AWS Console:

Go to EC2 → Launch Instance.

Select Ubuntu 22.04 AMI.

Choose t3.medium type.

Place inside Private Subnet C.

Disable Public IP.

Attach the App EC2 Security Group.

Add IAM Role if needed (for SSM access).

Launch the instance.











3.2 Connecting to Private EC2

Since the instance is private, we used one of two methods:

Through Bastion Host (in Public Subnet):

ssh -i mykey.pem ubuntu@<Bastion-Public-IP>

ssh ubuntu@<Private-EC2-Private-IP>

Via AWS SSM Session Manager:
If IAM role with AmazonSSMManagedInstanceCore was attached:

Open AWS Systems Manager → Session Manager → Start Session.

Directly open shell into private EC2.





3.3 Updating the System

Once inside the private EC2:

sudo apt update -y

sudo apt upgrade -y

This ensures all system packages are up to date.



3.4 Installing Java (OpenJDK 17)

Spring PetClinic requires Java 17.

sudo apt install openjdk-17-jdk -y

java -version

Expected output:

3.5 Installing Git and Maven

We needed both Git (to clone the PetClinic repo) and Maven (to build the project).

sudo apt install git maven -y

git --version

mvn -v

Expected output:

Git version (e.g., 2.34.1)

Apache Maven version (3.8.x)



3.6 Cloning the Spring PetClinic Repository

Navigate to /opt and clone the official repo:

cd /opt

sudo git clone https://github.com/spring-projects/spring-petclinic.git

cd spring-petclinic





3.7 Building the Application

We then packaged the application into a .jar file:

sudo mvn package

Maven downloaded dependencies (this took a while).

At the end, the .jar file was generated inside the target directory.

Navigate to target folder:

cd target

ls

Expected output:

spring-petclinic-3.5.0-SNAPSHOT.jar







3.8 Running the Application

Run the application on port 8080:

sudo java -jar spring-petclinic-3.5.0-SNAPSHOT.jar

At this point:

Spring Boot started an embedded Tomcat server.

Logs showed:

Tomcat started on port(s): 8080 (http)

Started PetClinicApplication in XX seconds



3.8 Running the Application

Run the application on port 8080:

sudo java -jar spring-petclinic-3.5.0-SNAPSHOT.jar

At this point:

Spring Boot started an embedded Tomcat server.

Logs showed:

Tomcat started on port(s): 8080 (http)

Started PetClinicApplication in XX seconds



3.9 Verifying Application Service

We verified that the application was listening:

sudo ss -tulnp | grep 8080

Output:

tcp   LISTEN 0      100    *:8080    *:*    users:(("java",pid=1261,fd=9))

This confirmed PetClinic was running on port 8080.



3.10 Making it Run in Background (Optional)

Instead of tying up the SSH session, we could run it as a background process:

nohup sudo java -jar spring-petclinic-3.5.0-SNAPSHOT.jar > petclinic.log 2>&1 &

nohup → makes process immune to logout.

& → runs in background.

Logs stored in petclinic.log.

Check running process:

ps aux | grep spring-petclinic















