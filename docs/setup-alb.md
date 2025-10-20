# Section 5: Load Balancer Setup (Application Load Balancer - ALB)

We used an Application Load Balancer (ALB) because:

It supports HTTP/HTTPS (Layer 7).

It can do health checks to only send traffic to healthy EC2s.

It scales automatically across multiple Availability Zones.







5.1 Security Group for the ALB

Before creating the ALB, we needed a Security Group that allowed public access.

Go to EC2 → Security Groups → Create Security Group.

Name: alb-sg.

Inbound Rules:

HTTP (80) → Source: 0.0.0.0/0

(Optional) HTTPS (443) → Source: 0.0.0.0/0

Outbound: Allow all traffic (default).





5.2 Creating the Target Group

A Target Group is required to tell the ALB where to send traffic (our app EC2).

Go to EC2 → Target Groups → Create Target Group.

Choose: Instances.

Name: petclinic-tg.

Protocol: HTTP.

Port: 8080 (because PetClinic runs on 8080).

VPC: Three-Tier-VPC.

Health Check settings:

Protocol: HTTP

Path: / (PetClinic home page responds on /).

Port: Traffic Port (8080).

Success codes: 200 (OK).

Healthy threshold: 2.

Unhealthy threshold: 2.

Timeout: 5s.

Interval: 10s.

Register Targets:

Select the Private EC2 instance running PetClinic.

Port: 8080.

Click Add to registered.

















5.3 Creating the Application Load Balancer

Now we expose the app to the public through the ALB.



Go to EC2 → Load Balancers → Create Load Balancer.

Select Application Load Balancer.

Name: petclinic-alb.

Scheme: Internet-facing.

IP address type: IPv4.

Network Mapping:

VPC: Three-Tier-VPC.

Subnets: Select 2 Public Subnets in different Availability Zones (required by ALB).

Security Group: Select alb-sg.

Listeners:

Add HTTP:80 → Forward to petclinic-tg.

Click Create Load Balancer.



5.4 Verifying the ALB Health Checks

After a few minutes, check Target Group → Targets tab.

Status should show healthy 

If it shows unhealthy:

Confirm PetClinic is running on port 8080 (sudo lsof -i :8080).

Confirm inbound SG rule of EC2 allows 8080 traffic from ALB SG.

Confirm health check path / is valid.



5.5 Accessing the Application

Once targets are healthy:

Copy the ALB DNS name from the console, e.g.:

petclinic-alb-123456789.me-central-1.elb.amazonaws.com

Open it in browser:

http://petclinic-alb-123456789.me-central-1.elb.amazonaws.com

You should see the Spring PetClinic home page.



5.6 Troubleshooting (If Needed)

Sometimes ALB may fail. Here’s how we handled it:

502 Bad Gateway → Usually means ALB can’t reach the target.

Fix: Ensure EC2 SG allows inbound 8080 from ALB SG.

Health check unhealthy →

Fix: Confirm PetClinic responds on /. If app is on a different path (e.g. /petclinic), update health check path

