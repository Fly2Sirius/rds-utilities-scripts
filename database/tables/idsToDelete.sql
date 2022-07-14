CREATE TABLE `idsToDelete` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `IdsToDelete` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `borrowerIdsToDelete_borrowerId` (`IdsToDelete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;