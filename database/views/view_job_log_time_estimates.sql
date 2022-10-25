CREATE DEFINER VIEW `job_log_time_estimates`
AS SELECT
   `l`.`job_name` AS `Job Name`,
   `s`.`step_name` AS `Step Name`,
   `s`.`loops_total` AS `Total Loops`,
   `s`.`loops_complete` AS `Current Loop`,concat(round(((`s`.`loops_complete` / `s`.`loops_total`) * 100),1),'%') AS `Percent Complete (Loops)`,
   `s`.`increment` AS `increment`,
   `s`.`start` AS `Step Start`,
   `s`.`end` AS `Step End`,
   `s`.`total_rows_to_update` AS `Total Number Of Rows To Update`,timestampdiff(MINUTE,`s`.`start`,ifnull(`s`.`end`,now())) AS `Run Time (Min)`,round((timestampdiff(MINUTE,`s`.`start`,ifnull(`s`.`end`,now())) / 60),2) AS `Run Time (hr)`,round(((timestampdiff(MINUTE,`s`.`start`,ifnull(`s`.`end`,now())) / ifnull(`s`.`loops_complete`,1)) * (`s`.`loops_total` - ifnull(`s`.`loops_complete`,0))),0) AS `Est Time Remaining`,(timestampdiff(MINUTE,`s`.`start`,ifnull(`s`.`end`,now())) + round(((timestampdiff(MINUTE,`s`.`start`,ifnull(`s`.`end`,now())) / ifnull(`s`.`loops_complete`,1)) * (`s`.`loops_total` - ifnull(`s`.`loops_complete`,0))),0)) AS `Estimated Total Run Time`,if((round(((timestampdiff(MINUTE,`s`.`start`,ifnull(`s`.`end`,now())) / ifnull(`s`.`loops_complete`,1)) * (`s`.`loops_total` - ifnull(`s`.`loops_complete`,0))),0) > 0),(now() + interval round((((timestampdiff(MINUTE,`s`.`start`,ifnull(`s`.`end`,now())) / ifnull(`s`.`loops_complete`,1)) * (`s`.`loops_total` - ifnull(`s`.`loops_complete`,0))) * 2.25),0) minute),NULL) AS `Estimated Completion Time`
FROM (`job_log_steps` `s` join `job_log` `l` on((`s`.`job_id` = `l`.`id`)));