#!/usr/bin/env python3
from boto3 import client
import boto3
import json
import pprint

rds = boto3.client('rds')

#response = rds_client.describe_db_instances()
#response = json.loads(client.describe_db_instances())
#obj = json.dumps(client.describe_db_instances(), indent=4)

#pprint(dict(response))

#for item in response:
#    print("key : {}, Value : {}".format(item,response[item]))
# print("Clusters")
# try:
# # get all of the db instances
#     dbs = rds.describe_db_clusters(
#         DBClusterIdentifier='',
#         Filters=[
#             {
#                 'Name': 'engine',
#                 'Values': [
#                     'aurora-mysql',
#                 ]
#                 # ,
#                 # 'Name': 'DBInstanceClass',
#                 # 'Values': [
#                 #     'db.serverless',
#                 # ]
#             }]
#     )
#     for db in dbs['DBClusters']:
#         print (db['DBClusterIdentifier']
#             #,db['Engine']
#             #,db['DBClusterMembers']['DBInstanceIdentifiers'][1]
#             )
#             #db['Endpoint']['Port'],
#             #db['DBInstanceStatus'])
# except Exception as error:
#     print(error)

print("Instances")
try:
# get all of the db instances
    dbs = rds.describe_db_instances(
        DBInstanceIdentifier='',
        Filters=[
            {
                'Name': 'engine',
                'Values': [
                    'aurora-mysql',
                ],
                'Name':'TagList', 
                'Values': [ 
                    {'Key': 'datadog_monitor_cluster', 'Value': 'prod'}
                ]
                #,
                # 'Name': f'tag:{copyFromName}',
                # 'Values': 'production'
            }]
    )
    for db in dbs['DBInstances']:
        #print (db['DBInstanceIdentifier']
            #,db['Engine']
            #,db['DBClusterMembers']['DBInstanceIdentifiers'][1]
        #   )
        print(db)
            #db['Endpoint']['Port'],
            #db['DBInstanceStatus'])
except Exception as error:
    print(error)

# try:
# # get all of the db instances
#     dbs = rds.describe_db_clusters(
#         DBClusterIdentifier='production-homeportal-1e1c8080-f217-49ad-9f0b-cb7aec17b44e'
#     )
#     #print (db)
# except Exception as error:
#     print(error)