truncate table optimus.partnerCommissions;

LOAD DATA FROM S3  's3://lendio-snowflake-exports/Partners_SPIFF_data.csv'
IGNORE INTO TABLE optimus.partnerCommissions
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines
(processingId,id,recordType,userName,payoutAmount,statementPeriodStartDate,revenue,payoutRuleName,planName,userExternalId,borrowerId, `name`,currentBorrowerStatus,stage,mineralGroup,phone,street,street2,city,`state`,zip,dateClosed,fundedAmount,acceptedOfferId, `type`,loanProductCategoryType,loanProductLenderId,points,housePoints,buyRate,paymentFrequency,paymentAmount,factor,term,numPayments,interestRate,offerReceivedAt,offerAcceptedAt,opportunityId,oppStart,oppEnd,disposition,appCompletedAt,appSent,docPrep,marketingId);