CREATE USER "ZABBIX" IDENTIFIED BY "pass";
GRANT "CONNECT" TO "ZABBIX";
grant select on v_$instance to zabbix;
grant select on v_$sysstat to zabbix;
grant select on v_$session to zabbix;
grant select on dba_free_space to zabbix;
grant select on dba_data_files to zabbix;
grant select on dba_tablespaces to zabbix;
grant select on v_$log to zabbix;
grant select on v_$archived_log to zabbix;
grant select on v_$loghist to zabbix;
grant select on v_$system_event to zabbix;
grant select on v_$event_name to zabbix;
grant select on v_$locked_object to zabbix;
grant select on v_$process to zabbix;
grant select on DBA_TABLESPACE_USAGE_METRICS to zabbix;
-- adg lag
grant select on V_$DATAGUARD_STATS to zabbix;
--backup
grant select on v_$rman_backup_job_details to zabbix ;
-- check temporary tablespace usage
grant select on dba_temp_free_space to zabbix ;
