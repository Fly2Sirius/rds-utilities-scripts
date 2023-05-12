    SET group_concat_max_len = 1000000;

create view datateam.userRolePermissions as
    select role,users,ifnull(`schema`,'*') as `schema`,ifnull(`privileges`,'*') as `privileges` from (
    select concat("`",FROM_user,"`@`",to_host,"`") as `garbage` ,
    from_user as `role`,
    group_concat(DISTINCT TO_USER  SEPARATOR ', ') as `users`,sp.table_schema as `schema`, sp.`privileges` from mysql.role_edges re
    left join (
        select grantee,group_concat(DISTINCT table_schema SEPARATOR ', ') as table_schema,group_concat(DISTINCT privilege_type  SEPARATOR ', ') as `privileges` from information_schema.SCHEMA_PRIVILEGES 
    where grantee not in ("'mysql.sys'@'localhost'","'mysql.session'@'localhost'")
    group by  grantee) sp on replace(replace(grantee,'\'',''),'@%','') = FROM_user
    group by 1) x
    where role not like 'AWS%';
    

    --  drop view datateam.userRolePermissions;
    
    -- select * from datateam.userRolePermissions;