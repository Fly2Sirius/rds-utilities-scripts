#for i in {1..24}
for i in $(seq -f "%02g" 2 24)
do 
  aws rds download-db-log-file-portion --db-instance-identifier reader-primary --output text --log-file-name slowquery/mysql-slowquery.log.2021-02-19.$i >> slowquery.txt
done
