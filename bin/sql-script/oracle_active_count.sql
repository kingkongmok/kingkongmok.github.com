Select count(1) From V$session where status='ACTIVE' and username <> 'SYSTEM' ; 
exit ;
