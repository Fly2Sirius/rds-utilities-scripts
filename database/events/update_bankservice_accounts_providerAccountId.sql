DROP EVENT IF EXISTS `optimus`.`update_bankservice_accounts_providerAccountId`;

DELIMITER ;;

CREATE EVENT `optimus`.`update_bankservice_accounts_providerAccountId` ON SCHEDULE EVERY 30 MINUTE STARTS '2023-05-04 13:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN

    call datateam.log('update bank_service accounts','start');


    update bank_service.accounts t
    set t.providerAccountid = case when t.id like "finicity%" then REPLACE(t.id,"finicity-","") 
        when t.id like "unit%" then REPLACE(t.id,"unit-","")
        ELSE t.id
    END 
    ,t.providerId = IF(SUBSTRING_INDEX(t.id, "-", 1) = "finicity",1,2)-- provider
    ,t.providerBankId =case when t.bankId like "finicity%" then REPLACE(t.bankId,"finicity-","") 
    when t.bankId like "unit%" then REPLACE(t.bankId,"unit-","")
        ELSE t.bankId
    END
    where t.providerAccountId is NULL;

    call datateam.log(NULL,'end');

END;;
DELIMITER ;

