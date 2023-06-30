#!/usr/bin/env python3
import boto3
import sys
import os
import json
import funcs as f
import mysql.connector
from mysql.connector import Error
from mysql.connector import errorcode
import colorama
from colorama import Fore
from rich.console import Console
console = Console()

if len(sys.argv) > 1:
    username = sys.argv[1]
else:
    print("You must supply a username: createUser username")
    sys.exit()

server_list = "./config/dbServerList_Writers.txt"
mysql_port = 3306
mysql_user, mysql_password = f.get_mysql_credentials()
mysql_database = "mysql"
instance_list = f.get_endpoint_value_by_key("EndpointType","WRITER")

for mysql_host in instance_list:
    
    connection = None
    try:
        connection = mysql.connector.connect(
            host=mysql_host,
            user=mysql_user,
            passwd=mysql_password,
            port=mysql_port,
            database=mysql_database,
        )
    except mysql.connector.Error as err:
        if err.errno == 2003:
            print(
                Fore.YELLOW
                + f"Unable to reach host: {mysql_host}" 
                + Fore.RESET
            )
        elif err.errno == 1045:
            print(
                Fore.RED
                + f"Username or Password Issue: {mysql_host}"
                + Fore.RESET
            )
        elif err.errno == 1049:
            print(                
                Fore.YELLOW
                + f"Database `{mysql_database}` does not exist on {mysql_host}"
                + Fore.RESET
            )
        else:
            print(err)
        pass  
          
    else:
        print(
            Fore.GREEN
            + f"CONNECTED : {mysql_host}"
            + Fore.RESET
        )
        connection.close()
