-- Set up services databases

***services_production

CREATE ROLE `financial_integration_role`, `admin`, `developer`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO `admin`@`%` ;

***MySQL 8 - financial_integration

-- production-financial-integration-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
-- staging-financial-integration-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

-- financial_integration roles:
GRANT SELECT, SHOW VIEW ON `financial_integration`.* TO `developer`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, EXECUTE, SHOW VIEW ON ``financial_integration``.* TO `financial_integration_role`@`%`;

-- financial_integration
CREATE USER IF NOT EXISTS 'financial_integration'@'10.%.%.%';
ALTER USER 'financial_integration'@'10.%.%.%' IDENTIFIED BY '5oBDEfZBzfq2xKaLyk' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT financial_integration_role TO 'financial_integration'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `financial_integration` ``@`10.%.%.%`;

-- financial_integration_worker
CREATE USER IF NOT EXISTS 'financial_integration_worker'@'10.%.%.%';
ALTER USER 'financial_integration_worker'@'10.%.%.%' IDENTIFIED BY '8VLYPadQGMP3LDcYw3' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT financial_integration_role TO 'financial_integration_worker'@'10.%.%.%';
SET DEFAULT ROLE ALL TO `financial_integration_worker`@`10.%.%.%`;



production-tax-service.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com
staging-tax-service.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com


production-bank-service.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com
staging-bank-service.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com

production-smb-invoices-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
staging-smb-invoices-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

production-smb-notifications-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
staging-smb-notifications-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

production-business-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
staging-business-service-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com

production-cashflow-enrichment-api-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
staging-cashflow-enrichment-api-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com
