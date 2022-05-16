aws rds describe-db-clusters --no-paginate \
    --query "DBClusters[?contains(DBClusterIdentifier, 'production-homeportal')] | sort_by(@, &ClusterCreateTime)[].[DBClusterIdentifier][] | [0:-3:1]"
    
    
    #.[DBClusterIdentifier,ClusterCreateTime]"
    #2022-05-11T14:18:10.542000+00:00



