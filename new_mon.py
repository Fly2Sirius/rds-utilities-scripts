#!/usr/bin/env python3

import time
import funcs as f
from rich.console import Console

mysql_host = "reader-bi.civpyhkigzas.us-east-1.rds.amazonaws.com"
#mysql_host = 'production.civpyhkigzas.us-east-1.rds.amazonaws.com'
mysql_port = 3306
mysql_user, mysql_password = f.get_mysql_credentials()

mysql_database = "optimus"
connection = f.create_connection(
    mysql_host, mysql_user, mysql_password, mysql_port, mysql_database
)
cursor = connection.cursor()


processlist = f"select ID,DB,Host,User,Command,Time, \
    left(Info,50) \
    as Query from information_schema.processlist \
    where Command not in ('Binlog Dump','Sleep','Connect','Daemon') \
    and Time > 1 \
    order by time desc limit 10;"

try:
    cursor.execute(processlist)
    count = cursor.fetchall()
except mysql.connector.ProgrammingError as err:
    print(
        Fore.RED
        + f"An error occured checking for FK orphans -> {err.msg}"
        + Fore.RESET
    )
    # pass
    count = 0
except mysql.connector.Error as err:
    print(err)

print(count)












exit()













console = Console()

with console.status("Monkeying around...", spinner="squareCorners"):
    time.sleep(10   )