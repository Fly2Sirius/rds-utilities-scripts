 CREATE TABLE `datateam`.`ForeignKeys` (
  `Constraint_Schema` varchar(64) NOT NULL DEFAULT '',
  `Constraint_Name` varchar(64) NOT NULL DEFAULT '',
  `Source_Schema` varchar(64) NOT NULL DEFAULT '',
  `Source_Table` varchar(64) NOT NULL DEFAULT '',
  `Source_Column` varchar(64) NOT NULL DEFAULT '',
  `Referenced_Schema` varchar(64) DEFAULT NULL,
  `Referenced_Table` varchar(64) DEFAULT NULL,
  `Referenced_Column` varchar(64) DEFAULT NULL
) ENGINE=InnoDB

