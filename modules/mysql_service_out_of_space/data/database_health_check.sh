

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