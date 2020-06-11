#!/bin/sh - 

if [ $# != 1 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

ErrMessage=""
ErrCount=0

PROCESS_LIST=( 

    ntpd ora_pmon ora_smon ora_lgwr ora_dbw ora_ckpt ora_cjq ora_mman ora_reco ora_s             # -- oracle instance
    asm_pmon asm_smon asm_lgwr asm_dbw asm_ckpt             # -- oracle asm
    ora_lmd ora_lck ora_lmon ora_lms ora_diag ora_asmb ora_rbal ora_lmhb ora_rms ora_rsmn ora_gtx ora_acms #ora_onnn ora_rcbg 
    ora_arch #ora_lns                            # -- adg primary
    #ora_rfs ora_mrp ora_pr ora_lsp                # -- adg standby

)


for (( CNTR=0; CNTR<"${#PROCESS_LIST[@]}"; CNTR+=1 )); do
    THISPROCESS="${PROCESS_LIST[$CNTR]%/}"
    if [ -z "`pgrep -f $THISPROCESS`" ] ; then
    	ErrMessage+=" $THISPROCESS" 
	((ErrCount++))
    fi 
done



case $1 in

'info')
	[ -z "$ErrMessage" ] || echo "Process not found: \"$ErrMessage\"." ;
	;;

'count')
	echo $ErrCount
	;;

*)
        echo "ZBX_NOTSUPPORTED"
        rval=1
        exit $rval
        ;;
esac


rval=$?

if [ "$rval" -ne 0 ]; then
  echo "ZBX_NOTSUPPORTED"
fi

exit $rval
