create database DATABASE_NAME;

CREATE ROLE `service_account`, `admin`, `developer`;
GRANT SELECT, SHOW VIEW ON `DATABASE_NAME`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO `admin`@`%` ;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON `database_name`.* TO `service_account`@`%`;
CREATE USER IF NOT EXISTS "USER1"@"10.%.%.%";
ALTER USER 'USER1'@'10.%.%.%' IDENTIFIED BY 'PASSWORD1';
CREATE USER IF NOT EXISTS 'USER2'@'10.%.%.%';
ALTER USER 'USER2'@'10.%.%.%' IDENTIFIED BY 'PASSWORD2';
GRANT service_account TO 'USER1'@'10.%.%.%';
GRANT service_account TO 'USER2'@'10.%.%.%';
SET DEFAULT ROLE service_account TO 'USER1'@'10.%.%.%','USER2'@'10.%.%.%';

CREATE USER IF NOT EXISTS 'kdavey'@'10.%.%.%';
ALTER USER 'kdavey'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*A1A1B0DEF3F1EFD139C3C23CE9ED70575955A4F4' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK; 
GRANT `rds_superuser_role`@`%` TO `kdavey`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `kdavey`@`10.%.%.%`;

CREATE USER IF NOT EXISTS 'semo'@'10.%.%.%';
ALTER USER 'semo'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*BAC88BA671D439E74E09FC2059B202FB8F8D2335' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT `rds_superuser_role`@`%` TO `semo`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `semo`@`10.%.%.%`;
