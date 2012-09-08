#! /bin/bash 

umask 007

killall -9 scriptIG.pl

SCRIPTS=`pwd`
cd ..
SUBMISSIONS=`pwd`/submissions
SUBMISSIONSGRADED=`pwd`/submissions.graded
cd $SCRIPTS

                                                                                
INPUTRC=$SCRIPTS/bash-readline-settings                                         

if [ ! -e $SUBMISSIONSGRADED ]
then
mkdir $SUBMISSIONSGRADED
chgrp grade310 $SUBMISSIONSGRADED
chmod 0770 $SUBMISSIONSGRADED
fi

SUBMISSIONSGRADED=$SUBMISSIONSGRADED/$USER

if [ ! -e $SUBMISSIONSGRADED ]
then
mkdir $SUBMISSIONSGRADED
chgrp grade310 $SUBMISSIONSGRADED
chmod 0770 $SUBMISSIONSGRADED
fi



PATH=/home/faculty1/sdc/201Spr12Grading/jdk/jdk1.7.0_03/bin:$PATH:.  
#Old fashioned setting.

PATH=/home/faculty1/sdc/310Spr12Grading/drjava:$PATH

ls $SUBMISSIONS

cd $SUBMISSIONS


#bash-readline-settings contains                                                
#set mark-directories off                                                       
#we can't just cat a line into the scripts directory                            
#because TAs might not have write access.                                       
read -e -p "Pick a submission:" subName
cd $SCRIPTS

$SCRIPTS/scriptIG.pl $SUBMISSIONS/$subName

chgrp grade310 `pwd`/reports/${USER}* `pwd`/reports/${USER}/*

echo "Did you grade $subName successfully?"
read -p "Type y to MOVE submission to the DONE dir, n to keep it:" yIn
if [ x$yIn = xy ]
  then
    mv  $SUBMISSIONS/$subName  $SUBMISSIONSGRADED/$subName

    others=$(getOtherSubmissions.pl $SUBMISSIONS $subName)
    if [ ! x"$others" == x ]
      then
        echo Do you want to move other submissions of same student too"?"
        echo $others
        read -p "Type y to MOVE them, n to not " yIn
        if [ x$yIn == xy ]
          then
            cd $SUBMISSIONS
            mv $others $SUBMISSIONSGRADED/$USER
        fi
        cd $SCRIPTS
    fi
fi




#./scriptIG.pl `pwd`/../submissions/student.2012-03-03-04-57-02
#./scriptIG.pl `pwd`/../submissions/multMain.2012-03-03-04-57-02
#./scriptIG.pl `pwd`/../submissions/nullCrash.2012-03-03-04-57-02


