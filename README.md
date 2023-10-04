
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# MySQL Service Out of Space.
---

This incident type refers to cases where the MySQL service, which is responsible for managing and storing data in a database, runs out of available space. This can happen due to a variety of reasons such as an unexpected increase in data volume or insufficient allocation of storage resources. When the MySQL service runs out of space, it can cause data loss, application errors, and even system crashes if not addressed promptly.

### Parameters
```shell
export MYSQL_DATA_DIRECTORY="PLACEHOLDER"

export MYSQL_LOG_DIRECTORY="PLACEHOLDER"

export DATABASE_PASSWORD="PLACEHOLDER"

export DATABASE_NAME="PLACEHOLDER"

export DATABASE_USERNAME="PLACEHOLDER"

export TABLE_NAME="PLACEHOLDER"
```

## Debug

### Check available disk space
```shell
df -h
```

### Check the size of the MySQL data directory
```shell
du -sh ${MYSQL_DATA_DIRECTORY}
```

### Check the size of MySQL logs
```shell
du -sh ${MYSQL_LOG_DIRECTORY}
```

### Identify the largest tables in the MySQL database
```shell
mysql -u ${DATABASE_USERNAME} -p -e "SELECT table_schema as 'Database', table_name AS 'Table', ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)' FROM information_schema.TABLES ORDER BY (data_length + index_length) DESC;"
```

### Identify the largest databases in the MySQL instance
```shell
mysql -u ${DATABASE_USERNAME} -p -e "SELECT table_schema 'Database Name', SUM(data_length + index_length)/1024/1024 'Database Size (MB)' FROM information_schema.tables GROUP BY table_schema;"
```

### Check if any long-running queries are causing the issue
```shell
mysql -u ${DATABASE_USERNAME} -p -e "SHOW FULL PROCESSLIST;"
```

### The database is not being properly optimized, leading to inefficiencies and excessive use of storage space.
```shell


#!/bin/bash



# Set variables

DB_NAME=${DATABASE_NAME}

DB_USER=${DATABASE_USERNAME}

DB_PASS=${DATABASE_PASSWORD}



# Check database size

DB_SIZE=$(mysql -u $DB_USER -p$DB_PASS -s -N -e "SELECT SUM(data_length + index_length)/1024/1024 FROM information_schema.TABLES WHERE table_schema='$DB_NAME';")

echo "Current size of database $DB_NAME is $DB_SIZE MB."



# Check for inefficient queries

SLOW_QUERIES=$(mysql -u $DB_USER -p$DB_PASS -e "SHOW VARIABLES LIKE 'slow_query_log';" | awk '{print $2}')

if [ "$SLOW_QUERIES" == "ON" ]; then

  echo "Slow query logging is enabled. Checking for inefficient queries..."

  LOG_FILE=$(mysql -u $DB_USER -p$DB_PASS -e "SHOW VARIABLES LIKE 'slow_query_log_file';" | awk '{print $2}')

  sudo mysqldumpslow -s t $LOG_FILE

else

  echo "Slow query logging is not enabled. Consider enabling to identify inefficient queries."

fi



# Check for unused indexes

echo "Checking for unused indexes..."

sudo mysqltuner --optimize --quiet --skipsize --skipsec --skipidx --skipfrag --forcesql --nocolor --recommendations | grep "Remove unused"



# Check for fragmented tables

echo "Checking for fragmented tables..."

sudo mysqlcheck -u $DB_USER -p$DB_PASS --auto-repair --optimize --check --analyze --silent $DB_NAME


```

## Repair

### Optimize the database by removing duplicate or unused data, which will reduce storage requirements.
```shell


#!/bin/bash



# Set the database name

DB_NAME=${DATABASE_NAME}



# Set the table name

TABLE_NAME=${TABLE_NAME}



# Connect to the database

mysql -u ${DATABASE_USERNAME} -p${DATABASE_PASSWORD} $DB_NAME ${< EOF



# Remove duplicate data

DELETE t1 FROM $TABLE_NAME t1

INNER JOIN $TABLE_NAME t2

WHERE t1.id < t2.id

AND t1.data = t2.data;



# Remove unused data

DELETE FROM $TABLE_NAME

WHERE {condition_for_unused_data};



# Optimize the table

OPTIMIZE TABLE $TABLE_NAME;



EOF


```