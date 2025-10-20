#!/bin/bash
# Run Spring PetClinic app
cd /opt/spring-petclinic && sudo mvn package && java -jar target/spring-petclinic-*.jar &