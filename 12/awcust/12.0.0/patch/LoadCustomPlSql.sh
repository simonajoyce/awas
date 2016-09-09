# # Files will be downloaded to the $AWCUST_TOP/AMEX/NEW directory
# and renamed with a date and sequential number.
# =========================================================
# This Script will run every .sql file in the patch/sql
# Directory
# 
echo "Enter APPS Password"
 stty -echo                  #Turns echo off
 read APPS_PW
 stty echo                   #Turns echo on
echo ___________________________________________________
echo Time : `date +"%Y%m%d_%H%M%S"`
echo ___________________________________________________

export FOLDER="/u01/app/oracle/apps/apps_st/appl/awcust/12.0.0/patch/sql"

echo "Parameter Used List"
echo "FOLDER=$FOLDER"

echo "Processing files"
set i=1;
for file in $FOLDER/*.sql ;
do echo "Processing $file"  2>&1 | tee -a sqllog.txt;
   echo exit | sqlplus apps/$APPS_PW @$file 2>&1 | tee -a sqllog.txt
   echo "" 2>&1 | tee -a sqllog.txt;
done

echo "$i files processed"
echo "Now review sqllog.txt for errors."

echo "Process Complete"
fi

exit
