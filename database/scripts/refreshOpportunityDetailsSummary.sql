use optimus;

SET @job_steps = 0;
call `datateam`.`job_log_start`("Refresh Opportunity Details Summary Table",@job_steps,1,0,0,"Starting Job",@_log_id);

drop table if exists optimus._opportunityDetailsSummary;

create table optimus._opportunityDetailsSummary like optimus.opportunityDetailsSummary;

insert into optimus._opportunityDetailsSummary
SELECT ar.firstName AS agentFirstName, ar.lastName AS agentLastName,
        m.partnerOwnedStart AS ownershipStart
        , m.partnerOwnedEnd AS ownershipEnd
        , m.borrowerId as marketing_borrowerId
        , m.id AS marketingId
        , m.affiliateId,
        o.id AS opportunityId
        , o.start AS opportunityStart
        , o.reason AS opportunityStatusReason
        , lpcs.name AS loanProductCategory,
        b.id AS borrower_borrowerId
        , b.name AS borrowerName
        , b.status AS borrowerStatus
        , b.stage AS borrowerStage
        , b.mineralGroup AS borrowerMineralGroup,
        b.phone AS borrowerPhone
        , b.street AS borrowerStreet
        , b.street2 AS borrowerStreet2
        , b.city AS borrowerCity
        , b.stateId AS borrowerState
        , b.zipId AS borrowerZip
        , comissions.payoutAmount
        , comissions.revenue
        , comissions.payoutRuleName
        , comissions.recordType
        , comissions.planName,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.amount, null) AS amount,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.offerId, null) AS offerId,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.dealId, null) AS dealId,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.loanProductLenderId, null) AS loanProductLenderId,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.type, null) AS type,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.factor, null) AS factor,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.interestRate, null) AS interestRate,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.buyRate, null) AS buyRate,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.numPayments, null) AS numPayments,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.paymentFrequency, null) AS paymentFrequency,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.paymentAmount, null) AS paymentAmount,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.minPurchaseFee, null) AS minPurchaseFee,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.advanceRate, null) AS advanceRate,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.paymentTerm, null) AS paymentTerm,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.points, null) AS points,
        IF(d.dateClosed >= m.partnerOwnedStart AND d.dateClosed <= m.partnerOwnedEnd, d.housePoints, null) AS housePoints,
        IF((o.end >= m.partnerOwnedStart AND o.end <= m.partnerOwnedEnd) OR o.end IS null, o.end, '0000-00-00 00:00:00') AS opportunityEnd,
        IF((o.dealSent >= m.partnerOwnedStart AND o.dealSent <= m.partnerOwnedEnd) OR o.dealSent IS null, o.dealSent, '0000-00-00 00:00:00') AS dealSent,
        IF((o.attempted >= m.partnerOwnedStart AND o.attempted <= m.partnerOwnedEnd) OR o.attempted IS null, o.attempted, '0000-00-00 00:00:00') AS attempted,
        IF((o.contacted >= m.partnerOwnedStart AND o.contacted <= m.partnerOwnedEnd) OR o.contacted IS null, o.contacted, '0000-00-00 00:00:00') AS contacted,
        IF((o.docPrep >= m.partnerOwnedStart AND o.docPrep <= m.partnerOwnedEnd) OR o.docPrep IS null, o.docPrep, '0000-00-00 00:00:00') AS docPrep,
        IF((b.applicationComplete >= m.partnerOwnedStart AND b.applicationComplete <= m.partnerOwnedEnd) OR b.applicationComplete IS null, b.applicationComplete, '0000-00-00 00:00:00') AS appComplete,
        IF((o.offerReceived >= m.partnerOwnedStart AND o.offerReceived <= m.partnerOwnedEnd) OR o.offerReceived IS null, o.offerReceived, '0000-00-00 00:00:00') AS offerReceived,
        IF((o.offerAccepted >= m.partnerOwnedStart AND o.offerAccepted <= m.partnerOwnedEnd) OR o.offerAccepted IS null, o.offerAccepted, '0000-00-00 00:00:00') AS offerAccepted,
        IF((o.dealClosed >= m.partnerOwnedStart AND o.dealClosed <= m.partnerOwnedEnd) OR o.dealClosed IS null, o.dealClosed, '0000-00-00 00:00:00') AS dealClosed,
        IF((o.dealClosed >= m.partnerOwnedStart AND o.dealClosed <= m.partnerOwnedEnd) AND o.dealClosed IS NOT null, (SELECT dealClosed),
         IF((o.offerAccepted >= m.partnerOwnedStart AND o.offerAccepted <= m.partnerOwnedEnd) AND o.offerAccepted IS NOT null, (SELECT offerAccepted),
           IF((o.offerReceived >= m.partnerOwnedStart AND o.offerReceived <= m.partnerOwnedEnd) AND o.offerReceived IS NOT null, (SELECT offerReceived),
             IF((b.applicationComplete >= m.partnerOwnedStart AND b.applicationComplete <= m.partnerOwnedEnd) AND b.applicationComplete IS NOT null, (SELECT applicationComplete),
               IF((o.docPrep >= m.partnerOwnedStart AND o.docPrep <= m.partnerOwnedEnd) AND o.docPrep IS NOT null, (SELECT o.docPrep),
                 IF((o.contacted >= m.partnerOwnedStart AND o.contacted <= m.partnerOwnedEnd) AND o.contacted IS NOT null, (SELECT contacted),
                   IF((o.attempted >= m.partnerOwnedStart AND o.attempted <= m.partnerOwnedEnd) AND o.attempted IS NOT null, (SELECT attempted), o.start))))))) AS lastActivity,
        IF((o.dealClosed >= m.partnerOwnedStart AND o.dealClosed <= m.partnerOwnedEnd) AND o.dealClosed IS NOT null, 'Funded',
          IF(((SELECT borrowerStage) = 'inactive'), (SELECT borrowerStatus),
            IF((o.offerAccepted >= m.partnerOwnedStart AND o.offerAccepted <= m.partnerOwnedEnd) AND o.offerAccepted IS NOT null, 'Deal In Progress',
              IF((o.offerReceived >= m.partnerOwnedStart AND o.offerReceived <= m.partnerOwnedEnd) AND o.offerReceived IS NOT null, 'Deal In Progress',
                IF((b.applicationComplete >= m.partnerOwnedStart AND b.applicationComplete <= m.partnerOwnedEnd) AND b.applicationComplete IS NOT null, 'Deal In Progress',
                  IF((o.docPrep >= m.partnerOwnedStart AND o.docPrep <= m.partnerOwnedEnd) AND o.docPrep IS NOT null, 'App Submitted',
                    IF((o.contacted >= m.partnerOwnedStart AND o.contacted <= m.partnerOwnedEnd) AND o.contacted IS NOT null, 'In Contact',
                      IF((o.attempted >= m.partnerOwnedStart AND o.attempted <= m.partnerOwnedEnd) AND o.attempted IS NOT null, 'Attempted', 'Lead Claimed')))))))) AS opportunityStatus
        from marketing m
        JOIN opportunities o ON o.marketingId = m.id
        JOIN borrowers b ON b.id = o.borrowerId
        LEFT JOIN marketingPartnerSubmissions mps ON mps.marketingId = m.id
        LEFT JOIN affiliateReps ar ON mps.affiliateRepId = ar.id
        LEFT JOIN (
            SELECT oe.opportunityId, d.id AS dealId, d.loanProductLenderId, d.type, off.amount, off.id AS offerId, d.dateClosed,
            off.factor, off.interestRate, off.buyRate, off.numPayments, off.paymentFrequency, off.paymentAmount, off.minPurchaseFee, off.advanceRate, off.paymentTerm,
            off.points, off.housePoints, d.loanProductCategoryId
            from opportunityEvents oe
            JOIN deals d ON d.id = oe.modelId
            JOIN offers off ON off.id = d.acceptedOfferId
            WHERE oe.modelType = 'deals'
            AND oe.type = 'dealClosed'
        )
        AS d ON d.opportunityId = o.id
        LEFT JOIN loanProductCategories lpcs ON lpcs.id = d.loanProductCategoryId
        LEFT JOIN partnerCommissions comissions ON comissions.opportunityId = o.id
        -- AND (o.start >= m.partnerOwnedStart AND o.start <= m.partnerOwnedEnd)
        WHERE (o.start >= m.partnerOwnedStart AND o.start <= m.partnerOwnedEnd)
        AND m.hasOwnership = 1;

-- create index affiliateId on optimus._opportunityDetailsSummary (affiliateId);

rename table optimus.opportunityDetailsSummary to optimus.opportunityDetailsSummaryOld;

rename table optimus._opportunityDetailsSummary to optimus.opportunityDetailsSummary;

drop table optimus.opportunityDetailsSummaryOld;


call `datateam`.`job_log_update`("errors",@@error_count);
call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);


# 15 06 * * *  ec2-user /home/ec2-user/partnerSpiff/refreshOpportunityDetailsSummary.sh