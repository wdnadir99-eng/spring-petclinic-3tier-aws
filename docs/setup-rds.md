# Section 4: Database Setup with Amazon RDS (MySQL)

The database tier is hosted in Amazon RDS for MySQL, which provides a managed, scalable relational database service. Unlike running MySQL on EC2, RDS handles backups, patching, and replication automatically.





4.1 Creating a Security Group for RDS

Before launching the database, we need a DB Security Group to control traffic.

Go to EC2 → Security Groups → Create Security Group.

Name: RDS-SG.

Inbound Rules:

MySQL/Aurora (3306)

Source: App-EC2-SG (so only app servers can connect).

Outbound: Allow all (default).

4.2 Creating the RDS Instance

Steps inside AWS Console:

Navigate to RDS → Databases → Create Database.

Choose Standard Create.

Engine: MySQL (8.0.x).

Template: Free Tier (for cost saving).

DB Identifier: three-tier-db.

Credentials:

Master username: admin.

Master password: yourpassword.

Instance type: db.t3.micro.

Storage: 20 GB (gp2).

Connectivity:



VPC: Three-Tier-VPC.

Subnet group: Select Private Subnets.

Public access: No.

Security group: Attach RDS-SG.

Additional settings:

Initial DB name: petclinic.

Click Create Database.

Wait ~10 minutes for the RDS instance to be available.





4.3 Verifying Connectivity from Private EC2

Once RDS was created, we tested the connection from our private EC2 where PetClinic is running.

Install MySQL client:

sudo apt install mysql-client -y

Test connection:

nc -vz three-tier-db.clmaggewmy20.me-central-1.rds.amazonaws.com 3306

Expected output:

Connection to three-tier-db.clmaggewmy20.me-central-1.rds.amazonaws.com 3306 port [tcp/mysql] succeeded!

Log in to MySQL:

mysql -h three-tier-db.clmaggewmy20.me-central-1.rds.amazonaws.com -u admin -p

Enter the password. You should see the MySQL shell:

mysql>





4.4 Creating the Database Schema

Inside MySQL shell:

CREATE DATABASE petclinic;

SHOW DATABASES;



4.5 Configuring Spring PetClinic to Use RDS

The PetClinic app by default uses an in-memory H2 database (not persistent). To connect it to MySQL, we edited the application.properties file.

Navigate to resources folder:

cd /opt/spring-petclinic/src/main/resources/

Edit the configuration:

sudo nano application.properties

Add the following lines:

spring.datasource.url=jdbc:mysql://three-tier-db.clmaggewmy20.me-central-1.rds.amazonaws.com:3306/petclinic

spring.datasource.username=admin

spring.datasource.password=yourpassword

spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver



spring.jpa.hibernate.ddl-auto=update

spring.jpa.show-sql=true

Save and exit (CTRL+O, CTRL+X).









































