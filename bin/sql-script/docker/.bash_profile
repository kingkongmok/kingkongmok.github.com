ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/EE; export ORACLE_HOME
ORACLE_SID=EE; export ORACLE_SID
PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH; export PATH
export EDITOR="vi"
alias sqlplus='rlwrap sqlplus'
alias rman='rlwrap rman'
