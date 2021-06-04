#!/bin/sh
#set -x
#检查表空间是否充足 valtpercent为表空间使用率阈值 vpartsize为分区FREE阈值
source /home/oracle/.bash_profile
valtpercent=85
vpartsize=100
vtablespace=(`sqlplus -S "/ as sysdba" <<EOF
        set feed off
        set heading off
        set timing off
        select tablespace_name ||'-'|| round(used_percent,2)
        from dba_tablespace_usage_metrics
        order by used_percent desc;
        quit
EOF`)

for tablespace in ${vtablespace[@]}
do
        vspace=`echo $tablespace|awk -F "-" '{print $1}'`
        vpercent=`echo $tablespace|awk -F "-" '{print $2}'`
        if [ `awk -v num1=${vpercent} -v num2=${valtpercent} 'BEGIN{print(num1>num2)?"1":"0"}'` -gt 0 ]
        then
                vresult="表空间${vspace}当前使用率为${vpercent}%,超过${valtpercent}%"
                vpath=(`sqlplus -S "/ as sysdba" <<EOF
        set feed off
        set heading off
        set timing off
        select distinct substr(file_name,2,instr(file_name,'/',1)-2) from dba_data_files where tablespace_name='${vspace}';
        quit
EOF`)
                for path in ${vpath[@]}
                do
                        vdiskinfo=`sqlplus -S "/ as sysdba"<<EOF
                        set feed off
                        set heading off
                        set timing off
                        select total_mb/1024||'-'||trunc(free_mb/1024/2) from v\\$asm_diskgroup where name='${vpath}';
                        quit
EOF`
                        vtotal=`echo ${vdiskinfo}|awk -F "-" '{print $1}'`
                        vfree=`echo ${vdiskinfo}|awk -F "-" '{print $2}'`
                        if [ `awk -v num1=${vfree} -v num2=${vpartsize} 'BEGIN{print(num1>num2)?"1":"0"}'` -gt 0 ]
                        then
                        vaddresu=`sqlplus -S "/ as sysdba" <<EOF
                                set timing off
                                alter tablespace ${vspace} add datafile;
EOF`
                        else
                        vresult=${vresult}":磁盘组${vpath}剩余空间不足,剩余空间为${vfree}G,表空间${vspace}添加数据文件失败"
                        fi
                done 
                if [[ "$vaddresu" = *"Tablespace altered"* ]]
                then
                vresult=${vresult}":表空间${vspace}添加数据文件成功"
                else
                vresult=${vresult}":表空间${vspace}添加数据文件失败"
                fi
                echo ${vresult}
        fi
done

