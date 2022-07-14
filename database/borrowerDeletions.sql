truncate table datateam.idsToDelete;

insert ignore into datateam.idsToDelete (idsToDelete) 
select borrowerId from optimus.threads x
left join optimus.borrowers b on x.borrowerId = b.id
    where b.id is NULL
    and x.borrowerId is NOT NULL
    and x.created > DATE_SUB(NOW(), INTERVAL 10 DAY)
    group by borrowerId;
   
delete x from optimus.threads x
join datateam.idsToDelete b on x.borrowerId = b.idsToDelete
where b.id between 1 and 5000;

truncate table datateam.idsToDelete;

insert ignore into datateam.idsToDelete (idsToDelete) 
select borrowerId from optimus.opportunities x
left join optimus.borrowers b on x.borrowerId = b.id
    where b.id is NULL
    and x.created > DATE_SUB(NOW(), INTERVAL 10 DAY)
    group by borrowerId;

delete x from optimus.opportunities x
join datateam.idsToDelete b on x.borrowerId = b.idsToDelete
where b.id between 1 and 5000;

truncate table datateam.idsToDelete;


insert ignore into datateam.idsToDelete (idsToDelete) 
select borrowerId from optimus.borrowerMatches x
left join optimus.borrowers b on x.borrowerId = b.id
    where b.id is NULL
    and x.created > DATE_SUB(NOW(), INTERVAL 10 DAY)
    group by borrowerId;

delete x from optimus.borrowerMatches x
join datateam.idsToDelete b on x.borrowerId = b.idsToDelete
where b.id between 1 and 5000;

delete x from optimus.borrowerMatches x
join datateam.idsToDelete b on x.borrowerId = b.idsToDelete
where b.id between 5000 and 10000;

truncate table datateam.idsToDelete;
   
   
insert ignore into datateam.idsToDelete (idsToDelete) 
select borrowerId from optimus.opportunityEvents x
left join optimus.borrowers b on x.borrowerId = b.id
    where b.id is NULL
    and x.created > DATE_SUB(NOW(), INTERVAL 30 DAY)
    group by borrowerId;
   
delete x from optimus.opportunityEvents x
join datateam.idsToDelete b on x.borrowerId = b.idsToDelete
where b.id between 1 and 5000;

truncate table datateam.idsToDelete;

insert ignore into datateam.idsToDelete (idsToDelete) 
select userId from optimus.userExperiments x
left join optimus.users u on x.userId = u.id
    where u.id is NULL
    -- and x.created > DATE_SUB(NOW(), INTERVAL 30 DAY)
    group by userId;
   
delete x from optimus.userExperiments x
join datateam.idsToDelete b on x.userId = b.idsToDelete
where b.id between 1 and 5000;

truncate table datateam.idsToDelete;




select min(id),max(id),count(*) from datateam.idsToDelete;
