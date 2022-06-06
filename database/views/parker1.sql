drop view if exists datateam.parker1;

create view datateam.parker1 as
SELECT
            concat(
                floor(timestampdiff(second, convert_tz(r.trx_started, '+00:00', 'America/Denver'), now())/60), 'm ',
                timestampdiff(second, convert_tz(r.trx_started, '+00:00', 'America/Denver'), now())%60, 's'
            ) as waiting_for,
            timestampdiff(second, convert_tz(r.trx_started, '+00:00', 'America/Denver'), now())%60 as `seconds`,
            concat('call mysql.rds_kill(', b.trx_mysql_thread_id, ');') as kill_blocker_command,
            concat('call mysql.rds_kill(', r.trx_mysql_thread_id, ');') as kill_waiting_command,
        #   r.trx_id waiting_trx_id,
        #   r.trx_mysql_thread_id waiting_thread,
            r.trx_query waiting_query,
        #   b.trx_id blocking_trx_id,
        #   b.trx_mysql_thread_id blocking_thread,
            b.trx_query blocking_query, # Null if blocking thread is idle
            (
                select group_concat(thread_id)
                from performance_schema.threads
                where processlist_id = b.trx_mysql_thread_id
            ) as blocking_threads, # Related threads
            (
                select group_concat(coalesce(sql_text, '<null>'))
                from performance_schema.threads
                join performance_schema.events_statements_current
                    on events_statements_current.thread_id = threads.thread_id
                where processlist_id = b.trx_mysql_thread_id
            ) as blocking_thread_queries_perf_schema,
            (
                select group_concat(coalesce(trx_query, '<null>'))
                from information_schema.innodb_trx as blocking_queries
                where trx_mysql_thread_id = b.trx_mysql_thread_id
            ) as blocking_thread_queries_innodb_trx,
            (
                select concat(user, '|', host, '@', db, ': ', coalesce(state, '<null>'))
                from information_schema.processlist
                where id = b.trx_mysql_thread_id
            ) as blocking_thread_status,
            (
                select concat(user, '|', host, '@', db, ': ', coalesce(state, '<null>'))
                from information_schema.processlist
                where id = r.trx_mysql_thread_id
            ) as waiting_thread_status,
            concat(bl.lock_table, ' ', bl.lock_type, ' lock for: ', bl.lock_data) as blocking_lock,
            concat(rl.lock_table, ' ', rl.lock_type, ' lock for: ', rl.lock_data) as wanted_lock
        FROM information_schema.innodb_lock_waits w
        INNER JOIN information_schema.innodb_trx b
            ON b.trx_id = w.blocking_trx_id
        INNER JOIN information_schema.innodb_trx r
            ON r.trx_id = w.requesting_trx_id
        join information_schema.innodb_locks bl
            on bl.lock_id = w.blocking_lock_id
        join information_schema.innodb_locks rl
            on rl.lock_id = w.requested_lock_id
        where timestampdiff(second, convert_tz(r.trx_started, '+00:00', 'America/Denver'), now())%60 > 1;