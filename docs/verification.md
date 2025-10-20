# Section 9: Final Verification, Screenshots, and Documentation Tips

This section ensures that the multi-tier PetClinic project is fully functional and ready for deployment verification. It also provides a framework for capturing screenshots and adding them to the documentation for non-IT readers.



9.1 Verify PetClinic Application on Private EC2

SSH into private EC2:

ssh -i your-key.pem ubuntu@<private-ec2-ip>

Check if the PetClinic app is running:

ps aux | grep spring-petclinic

Expected Output: A Java process with spring-petclinic-3.5.0-SNAPSHOT.jar should appear.

Verify the app is listening on port 8080:

sudo ss -tulpn | grep 8080

Expected Output: java process should show LISTEN on *:8080.





9.2 Verify RDS Connectivity

From private EC2, test MySQL connection to RDS:

nc -vz <rds-endpoint> 3306

Expected Output: Connection to <rds-endpoint> 3306 port [tcp/mysql] succeeded!

Optional: Verify database credentials and schema:

mysql -h <rds-endpoint> -u <db-username> -p

SHOW DATABASES;

USE <petclinic-db>;

SHOW TABLES;





9.3 Verify Load Balancer Connectivity

Access ALB DNS name in a browser:

http://petclinic-alb-public-1234567890.us-east-1.elb.amazonaws.com

Expected Result: PetClinic homepage loads.

Test other pages:

/owners/find → search owners

/vets.html → view veterinarians

/oups → triggers error page



9.4 Verify Target Group Health Checks

Go to EC2 → Target Groups → petclinic-tg → Targets.

Status should be healthy (green).

If unhealthy:

Verify security group of private EC2 allows traffic from ALB SG on port 8080.

Verify application is running.

Verify health check path is /.



9.5 Security Verification

ALB Security Group: Allows HTTP/HTTPS from anywhere.

Private EC2 Security Group: Allows HTTP from ALB SG only, SSH from your IP.

RDS Security Group: Allows MySQL from private EC2 only.









