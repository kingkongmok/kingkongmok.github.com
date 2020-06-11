#! /bin/sh

set -o nounset                              # Treat unset variables as an error

CRS_STAT=/oracle/11.2.0/grid/gridhome/bin/crs_stat

if [ $# != 1 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi


case $1 in

'count')
	result=`$CRS_STAT -t | perl -nae 'if ($F[2] =~ /ONLINE/){ $s++ unless $F[3] =~ /ONLINE/ } }{ $s=$s?$s:0; print $s'`
	rval=$?
	;;

'info')
	result=`$CRS_STAT -t | perl -nae 'if ($F[2] =~ /ONLINE/){ print "$F[0], " unless $F[3] =~ /ONLINE/ }'`
	rval=$?
	;;

*)
        echo "ZBX_NOTSUPPORTED"
        rval=1
        exit $rval
        ;;
esac

#if [ a"$result" == a"" ]; then
#    result="ok"
#fi 

if [ "$rval" -ne 0 ]; then
    echo "ZBX_NOTSUPPORTED"
else
    echo $result
fi

exit $rval
