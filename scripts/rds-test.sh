#!/bin/bash
# Test RDS connection
mysql -h <rds-endpoint> -u <db-username> -p -e 'SHOW DATABASES;'