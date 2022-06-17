#!/bin/bash
START="$(date +%s)"

mysqldump --column-statistics=0 --set-gtid-purged=OFF -h homeportal-rc.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com --databases wordpress | mysql -h hp-rc-clone-test2.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com


DURATION=$[ $(date +%s) - ${START} ]
echo ${DURATION}

