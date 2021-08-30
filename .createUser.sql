CREATE USER IF NOT EXISTS 'USERNAME'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' BY 'PASSWORD_STRING' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK
GRANT USAGE ON *.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `etl`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `archive`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `lenders`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `lendioPerformanceInsights`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `lenderData`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `wordpress`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `urls`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `oauth`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `logs`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `optimus`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `franchise_portal`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `%_lenders`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `%_oauth`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `%_logs`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `%_urls`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `%_wordpress`.* TO 'USERNAME'@'10.%.%.%'
GRANT SELECT, EXECUTE, SHOW VIEW ON `%_optimus`.* TO 'USERNAME'@'10.%.%.%'