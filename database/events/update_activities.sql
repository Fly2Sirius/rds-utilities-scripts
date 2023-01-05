DROP EVENT IF EXISTS `optimus`.`update_activities`;

DELIMITER ;;

CREATE EVENT `optimus`.`update_activities` ON SCHEDULE EVERY 5 MINUTE STARTS '2022-01-04 16:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN

    DROP TEMPORARY TABLE IF EXISTS `optimus`._recentActivities;

    call `datateam`.`job_log_start`("update_activities",1,1,0,0,"Running",@_log_id);


    create temporary table `optimus`._recentActivities     
        select a.borrowerId, a.activityId, aa.`type` as activityType from optimus.activities aa
        join (
        select borrowerid, max(id) as activityId from optimus.activities 
        WHERE modified > date_sub(now(), interval 5 minute) group by borrowerId 
        ) a on aa.id = a.activityId;

    SET @activity_count = (select count(1) from `optimus`._recentActivities);

    call `datateam`.`job_log_update`("increment",@activity_count);

    UPDATE `optimus`.borrowers b, `optimus`._recentActivities r
    SET b.lastActivityId = r.activityId, b.lastActivityType = r.activityType
    WHERE b.id = r.borrowerId;

    UPDATE `optimus`.deals d, `optimus`._recentActivities r
    SET d.lastActivityId = r.activityId, d.lastActivityType = r.activityType
    WHERE d.borrowerId = r.borrowerId;

    DROP TEMPORARY TABLE IF EXISTS optimus._recentActivities;

    call `datateam`.`job_log_update`("status","Complete");
    call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);

END;;
DELIMITER ;

