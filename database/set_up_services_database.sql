-- Set up services databases
-- production-services-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-services-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
CREATE ROLE IF NOT EXISTS `enrichment_service_role`,`business_service_role`,`notifications_service_role`,`embedded_service_role`,`payments_service_role`,`invoices_service_role`,`bank_service_role`,`tax_service_role`,`fin_integration_service_role`, `admin`, `developer`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO `admin`@`%` ;


-- MySQL 8 - financial_integration finsdb
-- production-financial-integration-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-financial-integration-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

-- set up database
create database if not exists `financial_integration`;

-- financial_integration roles:
GRANT SELECT, SHOW VIEW ON `financial_integration`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON `financial_integration`.* TO `fin_integration_service_role`@`%`;

-- financial_integration
CREATE USER IF NOT EXISTS 'financial_integration'@'10.%.%.%';
ALTER USER 'financial_integration'@'10.%.%.%' IDENTIFIED BY '5oBDEfZBzfq2xKaLyk' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT fin_integration_service_role TO 'financial_integration'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `financial_integration`@`10.%.%.%`;

-- financial_integration_worker
CREATE USER IF NOT EXISTS 'financial_integration_worker'@'10.%.%.%';
ALTER USER 'financial_integration_worker'@'10.%.%.%' IDENTIFIED BY '8VLYPadQGMP3LDcYw3' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT fin_integration_service_role TO 'financial_integration_worker'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `financial_integration_worker`@`10.%.%.%`;

-- MySQL 8 - tax_service
-- production-tax-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-tax-service-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

-- set up database
create database if not exists `tax_service`;

-- tax_service roles:
GRANT SELECT, SHOW VIEW ON `tax_service`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON `tax_service`.* TO `tax_service_role`@`%`;

-- tax_service
CREATE USER IF NOT EXISTS 'tax_api'@'10.%.%.%';
ALTER USER 'tax_api'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*5ABFC154EA7AFCC1E73FB9829C6EA64B0A2C4DDB' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT tax_service_role TO 'tax_api'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `tax_api`@`10.%.%.%`;

-- tax_service_worker
CREATE USER IF NOT EXISTS 'tax_api_worker'@'10.%.%.%';
ALTER USER 'tax_api_worker'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*998EC8D6EA1DAFA657304BC021EE0CFA5224EED6' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT tax_service_role TO 'tax_api_worker'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `tax_api_worker`@`10.%.%.%`;

-- MySQL 8 - smb_invoices_service_-service
-- production-smb-invoices-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-smb-invoices-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

-- set up database
create database if not exists `smb-invoices-service`;

-- smb_invoices_service roles:
GRANT SELECT, SHOW VIEW ON `smb_invoices_service`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON `smb_invoices_service`.* TO `invoices_service_role`@`%`;

-- smb_invoices_service
CREATE USER IF NOT EXISTS 'smb_invoices_service'@'10.%.%.%';
-- PRODUCTION
ALTER USER 'smb_invoices_service'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*D030961757E0DE0DCF082C8695BDE25BB159EFDE' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
--STAGING
-- ALTER USER 'smb_invoices_service'@'10.%.%.%' IDENTIFIED BY '5QBW8TO18CUCLUM' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT invoices_service_role TO 'smb_invoices_service'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `smb_invoices_service`@`10.%.%.%`;
-- smb_invoices_service_worker
CREATE USER IF NOT EXISTS 'smb_invoices_service_worker'@'10.%.%.%';
-- PRODUCTION
ALTER USER 'smb_invoices_service_worker'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*8955ECC34F5AE1D165C91BB8FF09EA6C65CE8716' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
-- STAGING
-- ALTER USER 'smb_invoices_service_worker'@'10.%.%.%' IDENTIFIED BY '6ELCWUC09MKVRBV' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT invoices_service_role TO 'smb_invoices_service_worker'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `smb_invoices_service_worker`@`10.%.%.%`;


-- MySQL 8 - smb_payments_service_worker-service
-- production-smb-payments-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-smb-payments-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
create database if not exists `smb_payments_service`;

-- smb_payments_service roles:
GRANT SELECT, SHOW VIEW ON `smb_payments_service`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON `payments_service_role`.* TO `smb_payments_role`@`%`;

-- smb_payments_service
CREATE USER IF NOT EXISTS 'smb_payments_service'@'10.%.%.%';
ALTER USER 'smb_payments_service'@'10.%.%.%' IDENTIFIED BY 'KCMT2KD1G5RIJYF' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
-- STAGING
-- ALTER USER 'smb_payments_service'@'10.%.%.%' IDENTIFIED BY 'U49KO2N5M2PPVXH' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT smb_paympayments_service_roleents_role TO 'smb_payments_service'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `smb_payments_service`@`10.%.%.%`;
-- smb_payments_service_worker
CREATE USER IF NOT EXISTS 'smb_payments_service_worker'@'10.%.%.%';
ALTER USER 'smb_payments_service_worker'@'10.%.%.%' IDENTIFIED BY 'OESO38KCEVSMCLH' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
-- STAGING
-- ALTER USER 'smb_payments_service_worker'@'10.%.%.%' IDENTIFIED BY 'XV86WLHR7RSHX6A' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT payments_service_role TO 'smb_payments_service_worker'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `smb_payments_service_worker`@`10.%.%.%`;

-- MySQL 8 - smb_notifications_service
-- production-smb-notifications-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-smb-notifications-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

-- set up database
create database if not exists `notifications`;

-- smb_notifications roles:
GRANT SELECT, SHOW VIEW ON `notifications`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON `notifications`.* TO `notifications_service_role`@`%`;

-- smb_notifications
CREATE USER IF NOT EXISTS 'smb_notifications'@'10.%.%.%';
ALTER USER 'smb_notifications'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*F26D0C38BB7676AF0C74097B68986E420F5555F2' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT notifications_service_role TO 'smb_notifications'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `smb_notifications`@`10.%.%.%`;
-- smb_notifications_worker
CREATE USER IF NOT EXISTS 'smb_notifications_worker'@'10.%.%.%';
ALTER USER 'smb_notifications_worker'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*3937C25829592F65E9029B1E40FF46978F14D0F7' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT notifications_service_role TO 'smb_notifications_worker'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `smb_notifications_worker`@`10.%.%.%`;


-- MySQL 8 - embedded_service

-- set up database
create database if not exists `embedded_service`;

-- embedded_service roles:
GRANT SELECT, SHOW VIEW ON `embedded_service`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON `embedded_service`.* TO `embedded_service_role`@`%`;

-- embedded_service
CREATE USER IF NOT EXISTS 'embedded_service'@'10.%.%.%';
ALTER USER 'embedded_service'@'10.%.%.%' IDENTIFIED BY '8jaiBvTsduufTxnU9f' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT embedded_service_role TO 'embedded_service'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `embedded_service`@`10.%.%.%`;
-- embedded_service_worker
CREATE USER IF NOT EXISTS 'embedded_service_worker'@'10.%.%.%';
ALTER USER 'embedded_service_worker'@'10.%.%.%' IDENTIFIED BY '8jai3fThuscRtnU9X' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT embedded_service_role TO 'embedded_service_worker'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `embedded_service_worker`@`10.%.%.%`;



bussdb -e "select CONCAT(\"call mysql.rds_kill(\",ID,\");\") from information_schema.processlist where user like '%service'"

bussdb -e "select * from information_schema.processlist where user like '%service'"

bspdb -e "select CONCAT(\"call mysql.rds_kill(\",ID,\");\") from information_schema.processlist where user like '%service'"

bspdb -e "select * from information_schema.processlist where user like '%service'"

ALTER USER 'bank_service'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*F8A0E76DD5A12C873E4FCAAFC03A1C09B417F17B' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;

mysql -hstaging-services-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com -e "select * from information_schema.processlist where user like '%service'"


-- production-bank-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-bank-service-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

mysqldump --column-statistics=0 --set-gtid-purged=OFF -hproduction-bank-service.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com bank_service | mysql -hproduction-services-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com bank_service
mysqldump --column-statistics=0 --set-gtid-purged=OFF -hstaging-bank-service.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com bank_service | mysql -hstaging-services-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com bank_service

mysqldump --column-statistics=0 --set-gtid-purged=OFF -hpproduction-cashflow-enrichment-api-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com enrichment_service | mysql -hproduction-services-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com enrichment_service
mysqldump --column-statistics=0 --set-gtid-purged=OFF -hstaging-cashflow-enrichment-api-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com enrichment_service | mysql -hstaging-services-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com enrichment_service


-- production-cashflow-enrichment-api-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-cashflow-enrichment-api-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com




















































-- MySQL 8 - bank_service
-- production-bank-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-bank-service-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

-- set up database
create database if not exists `bank_service`;

-- bank_service roles:
GRANT SELECT, SHOW VIEW ON `bank_service`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON `bank_service`.* TO `bank_service_role`@`%`;

-- bank_service
CREATE USER IF NOT EXISTS 'bank_api'@'10.%.%.%';
ALTER USER 'bank_api'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*E8A0E76DD5A12C873E4FCAAFC03A1C09B417F17B'  REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT bank_service_role TO 'bank_api'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `bank_api`@`10.%.%.%`;

-- bank_service_worker
CREATE USER IF NOT EXISTS 'bank_api_worker'@'10.%.%.%';
ALTER USER 'bank_api_worker'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*988877FEC187579AA5F4055724477943520CA16B' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT bank_service_role TO 'bank_api_worker'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `bank_api_worker`@`10.%.%.%`;

-- MySQL 8 - business_service
-- production-business-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-business-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

-- set up database
create database if not exists `business_service`;

-- business_service roles:
GRANT SELECT, SHOW VIEW ON `business_service`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON `business_service`.* TO `business_service_role`@`%`;

-- business_service
CREATE USER IF NOT EXISTS 'business_service'@'10.%.%.%';
ALTER USER 'business_service'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*829249BBF128E952C8340841CBAE82175C37B7A9' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT business_service_role TO 'business_service'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `business_service`@`10.%.%.%`;
-- business_service_worker
CREATE USER IF NOT EXISTS 'business_service_worker'@'10.%.%.%';
ALTER USER 'business_service_worker'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*D69DF5B319BE6B87BDF17E0C39D262E827AE5390' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT business_service_role TO 'business_service_worker'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `business_service_worker`@`10.%.%.%`;

-- MySQL 8 - enrichment_service
-- production-cashflow-enrichment-api-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-cashflow-enrichment-api-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

-- set up database
create database if not exists `enrichment_service`;

-- enrichment_service roles:
GRANT SELECT, SHOW VIEW ON `enrichment_service`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON `enrichment_service`.* TO `enrichment_service_role`@`%`;

-- enrichment_service
CREATE USER IF NOT EXISTS 'cashflow_enrichment'@'10.%.%.%';
ALTER USER 'cashflow_enrichment'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*6666877A7128B889335824863AF3AA4C472324A8' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT enrichment_service_role TO 'cashflow_enrichment'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `cashflow_enrichment`@`10.%.%.%`;
-- enrichment_service_worker
CREATE USER IF NOT EXISTS 'cashflow_enrichment_worker'@'10.%.%.%';
ALTER USER 'cashflow_enrichment_worker'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*4CB98DE648267710716DABCF72CF81CD54559832' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT enrichment_service_role TO 'cashflow_enrichment_worker'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `cashflow_enrichment_worker`@`10.%.%.%`;





-- Create Users
CREATE USER IF NOT EXISTS 'lendio_lake'@'%';
ALTER USER 'lendio_lake'@'%' IDENTIFIED WITH 'mysql_native_password' AS '*F4E971CB6C1217E863A77584F568076B13F43468' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT REPLICATION CLIENT, REPLICATION SLAVE, SELECT ON *.* TO 'lendio_lake'@'%';
GRANT SELECT ON `bank_service`.* TO 'lendio_lake'@'%';

CREATE USER IF NOT EXISTS 'djones'@'10.%.%.%';
ALTER USER 'djones'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*E6723A14E22B3FC8864003445B23AABAB3755B07' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT USAGE ON *.* TO `djones`@`10.%.%.%`;
GRANT `developer`@`%` TO `djones`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `djones`@`10.%.%.%`;

CREATE USER IF NOT EXISTS 'elarkin'@'10.%.%.%';
ALTER USER 'elarkin'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*316114F6E8A432367402E69137019181D245CFDC' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT USAGE ON *.* TO `elarkin`@`10.%.%.%`;
GRANT `developer`@`%` TO `elarkin`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `elarkin`@`10.%.%.%`;

CREATE USER IF NOT EXISTS 'sreader'@'10.%.%.%';
ALTER USER 'sreader'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*37223BE9C2A165C5AA34F85E5908A012798D32FD' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT USAGE ON *.* TO `sreader`@`10.%.%.%`;
GRANT `developer`@`%` TO `sreader`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `sreader`@`10.%.%.%`;

CREATE USER IF NOT EXISTS 'brussel'@'10.%.%.%';
ALTER USER 'brussel'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*F81F4235A34585043AD875CEDEDE78CF5B604880' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT USAGE ON *.* TO `brussel`@`10.%.%.%`;
GRANT `developer`@`%` TO `brussel`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `brussel`@`10.%.%.%`;

CREATE USER IF NOT EXISTS 'bshort'@'10.%.%.%';
ALTER USER 'bshort'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*A1343E11E9E584D77D5872D6C2E230789DB926CC' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT USAGE ON *.* TO `bshort`@`10.%.%.%`;
GRANT `developer`@`%` TO `bshort`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `bshort`@`10.%.%.%`;

CREATE USER IF NOT EXISTS 'mattstyles'@'10.%.%.%';
ALTER USER 'mattstyles'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*427D74072417FDEB8C8A89B3DAB9E2869C6CD4CC' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT USAGE ON *.* TO `mattstyles`@`10.%.%.%`;
GRANT `developer`@`%` TO `mattstyles`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `mattstyles`@`10.%.%.%`;

CREATE USER IF NOT EXISTS 'parker'@'10.%.%.%';
ALTER USER 'parker'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*840F9F4DAB4403CB940D140845D226E09554B9BC' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT USAGE ON *.* TO `parker`@`10.%.%.%`;
GRANT `admin`@`%` TO `parker`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `parker`@`10.%.%.%`;

CREATE USER IF NOT EXISTS 'bryanlee'@'10.%.%.%';
ALTER USER 'bryanlee'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*57795EBD9BCB513C8A719745029B8B1EF80D9029' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT USAGE ON *.* TO `bryanlee`@`10.%.%.%`;
GRANT `developer`@`%` TO `bryanlee`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `bryanlee`@`10.%.%.%`;

CREATE USER IF NOT EXISTS 'jstoutenburg'@'10.%.%.%';
ALTER USER 'jstoutenburg'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*C3912F2CA9B4ABA400862A1B1F28A2B448D2E387' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT USAGE ON *.* TO `jstoutenburg`@`10.%.%.%`;
GRANT `developer`@`%` TO `jstoutenburg`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `jstoutenburg`@`10.%.%.%`;

CREATE USER IF NOT EXISTS 'sethadamson'@'10.%.%.%';
ALTER USER 'sethadamson'@'10.%.%.%' IDENTIFIED WITH 'mysql_native_password' AS '*D77E7152C865C3303B522F0C202ED0E409D3C5A7' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT USAGE ON *.* TO `sethadamson`@`10.%.%.%`;
GRANT `developer`@`%` TO `sethadamson`@`10.%.%.%`;
SET DEFAULT ROLE ALL TO `sethadamson`@`10.%.%.%`;