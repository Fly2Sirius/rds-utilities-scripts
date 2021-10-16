from pathlib import Path
import os
from configparser import ConfigParser
import mysql.connector
from mysql.connector import Error
import colorama
from colorama import Fore


def get_mysql_credentials():
    home_dir = Path.home()
    conf = '.my.cnf'
    conf = os.path.join(home_dir,conf)
    config = ConfigParser()
    config.read(conf)
    mysql_user = config.get('client', 'user')
    mysql_password = config.get('client', 'password')
    return mysql_user,mysql_password

def create_connection(host_name, user_name, user_password,mysql_port,mysql_database):
    connection = None
    try:
        connection = mysql.connector.connect(
            host=host_name,
            user=user_name,
            passwd=user_password,
            port=mysql_port,
            database=mysql_database
        )
        print(f"Connection to {host_name} successful")
    except Error as e:
        print(f"The error '{e}' occurred")
        sys.exit()

    return connection

def send_slack_notification(users):
    s = requests.Session()
    s.headers.update({"Authorization": "GenieKey 9f746c3e-659b-4fca-aa81-6d0fa8022378", "Content-Type": "application/json"})
    url="https://api.opsgenie.com/v2/alerts"
    data = {
        "message": "Unknown MySQL Users Found",
    "description": "Unknown Users : "+str(users),
    "details": {
        "team": "apiStatus",
        "test": "true"
        }
    }       
    #x = s.post(url, data=json.dumps(data))
    print(json.dumps(data))


def show_table_information(connection,schema_name,table_name):
    cursor = connection.cursor()
    get_table_info = f"SELECT \
            TABLE_SCHEMA as `Schema`,TABLE_NAME AS `Table`, \
            cast(ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024 ) as UNSIGNED) AS `Total_Size_MB`, \
            cast(ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024 / 1024 ) as UNSIGNED) AS `Total_Size_GB`, \
            cast(SUM(ROUND((DATA_LENGTH) / 1024 / 1024) ) as UNSIGNED) AS `Data_Length_MB`, \
            cast(SUM(ROUND((INDEX_LENGTH)  / 1024 / 1024) )as UNSIGNED) AS `Index_Length_MB`, \
            cast(ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024)  *.00252,2) as CHAR) as `Estimated_Migration_Run_Time_Minutes`, \
            cast(format(DATA_LENGTH/AVG_ROW_LENGTH,0) as char) as Estimated_Rows \
            FROM information_schema.TABLES \
            where table_schema = '{schema_name}' \
            AND table_name ='{table_name}' \
            ORDER BY \
            (DATA_LENGTH + INDEX_LENGTH) \
            DESC;"

    cursor.execute(get_table_info)
    columns = cursor.description 
    table_size_data = [{columns[index][0]:column for index, column in enumerate(value)} for value in cursor.fetchall()]
    for value in table_size_data:
        print(Fore.CYAN + f"\n    Schema : {value['Schema']}")
        print(f"    Table : {value['Table']}")
        print(f"    Total Size (MB) : {value['Total_Size_MB']}")
        print(f"    Total Size (GB) : {value['Total_Size_GB']}")
        print(f"    Data Length (MB) : {value['Data_Length_MB']}")
        print(f"    Index Length (MB) : {value['Index_Length_MB']}")
        print(f"    Estimated Migration Run Time (Min) : {value['Estimated_Migration_Run_Time_Minutes']}")
        print(f"    Estimated Rows : {value['Estimated_Rows']}\n" + Fore.RESET)

def get_fk_information(connection,schema_name,table_name):
    cursor = connection.cursor()
    get_fk_info = f"(SELECT \
    constraint_schema `Constraint_Schema`, \
    constraint_name `Constraint_Name`, \
    table_schema `Source_Schema`, \
    table_name `Source_Table`, \
    column_name `Source_Column`, \
    referenced_table_schema `Referenced_Schema`, \
    referenced_table_name `Referenced_Table`, \
    referenced_column_name `Referenced_Column` \
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE \
    WHERE \
    table_schema = '{schema_name}' \
    AND table_name = '{table_name}' \
    AND referenced_column_name IS NOT NULL) \
    UNION \
    (SELECT \
        constraint_schema `Constraint_Schema`, \
        constraint_name `Constraint_Name`, \
        table_schema `Source_Schema`, \
        table_name `Source_Table`, \
        column_name `Source_Column`, \
        referenced_table_schema `Referenced_Schema`, \
        referenced_table_name `Referenced_Table`, \
        referenced_column_name `Referenced_Column` \
    FROM \
        INFORMATION_SCHEMA.KEY_COLUMN_USAGE \
    WHERE \
        referenced_table_schema = '{schema_name}' \
        AND referenced_table_name = '{table_name}' \
        AND table_name != 'counties');"

    cursor.execute(get_fk_info)
    columns = cursor.description 
    foreign_key_data = [{columns[index][0]:column for index, column in enumerate(value)} for value in cursor.fetchall()]
    return foreign_key_data