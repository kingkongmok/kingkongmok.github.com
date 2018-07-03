ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/EE; export ORACLE_HOME
ORACLE_SID=EE; export ORACLE_SID
PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH; export PATH
export TNS_ADMIN=$ORACLE_HOME/network/admin
export ORACLE_TERM=vt100
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export NLS_DATE_FORMAT="DD-MON-YYYY HH24:MI:SS"
export ORA_NLS11=$ORACLE_HOME/nls/data
#export LD_LIBRARY_PATH=$ORACLE_HOME/lib32:$ORACLE_HOME/lib:/usr/lib:/backup/ogg/11.2.1
#export LIBPATH=$ORACLE_HOME/lib:$ORACLE_HOME/lib32:$ORACLE_HOME/ctx/lib:/backup/ogg/11.2.1
#export CLASSPATH=$ORACLE_HOME/JRE/lib:$ORACLE_HOME/JRE/lib/rt.jar:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export EDITOR="vi"
export TEMP=/tmp
export TMP=/tmp
export TMPDIR=/tmp
/u01/app/oracle/product/11.2.0/EE/bin/rman cmdfile=/home/oracle/rman_full msglog=/home/oracle/full.log
