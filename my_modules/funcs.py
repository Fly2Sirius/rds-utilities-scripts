from pathlib import Path
import os
from configparser import ConfigParser
import mysql.connector
from mysql.connector import Error


def get_mysql_credentials():
    home_dir = Path.home()
    conf = '.my.cnf'
    conf = os.path.join(home_dir,conf)
    config = ConfigParser()
    config.read(conf)
    mysql_user = config.get('client', 'user')
    mysql_password = config.get('client', 'password')
    return mysql_user,mysql_password

def create_connection(host_name, user_name, user_password,port=3306):
    connection = None
    try:
        connection = mysql.connector.connect(
            host=host_name,
            user=user_name,
            passwd=user_password,
            port=port,
            database='datateam'
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