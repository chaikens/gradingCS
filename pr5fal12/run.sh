#! /bin/bash 

./setup.sh

umask 007

killall -9 scriptIG.pl

SCRIPTS=`pwd`


INPUTRC=$SCRIPTS/bash-readline-settings

if [ ! -e `pwd`/submissions.graded/$USER ]
then
mkdir `pwd`/submissions.graded/$USER
fi
chgrp grade201 `pwd`/submissions.graded/$USER


PATH=/home/faculty1/sdc/201Spr12Grading/jdk/jdk1.7.0_03/bin:$PATH:.  
#Old fashioned setting.

PATH=/home/faculty1/sdc/201Spr12Grading/drjava:$PATH


cd `pwd`/submissions
ls 
#bash-readline-settings contains
#set mark-directories off
#we can't just cat a line into the scripts directory
#because TAs might not have write access.
read -e -p "Pick a submission:" subName
cd ..

./scriptIG.pl `pwd`/submissions/$subName
#./scriptIG.pl `pwd`/submissions/student.2012-03-03-04-57-02


chgrp grade201 `pwd`/reports/${USER} `pwd`/reports/$USER.summary   `pwd`/reports/${USER}.no_report `pwd`/reports/${USER}/*

if [ -d `pwd`/WorkSamples ]
then
find `pwd`/WorkSamples -user $USER -exec chgrp grade201 '{}' \;
fi


echo "Did you grade $subName successfully?"
read -p "Type y to MOVE submission to the DONE dir, n to keep it:" yIn
if [ x$yIn = xy ]
  then
    mv  `pwd`/submissions/$subName  `pwd`/submissions.graded/$USER/$subName

    others=$(getOtherSubmissions.pl $(pwd)/submissions $subName)
    if [ ! x"$others" == x ]
      then
        echo Do you want to move other submissions of same student too"?"
        echo $others
        read -p "Type y to MOVE them, n to not " yIn
        if [ x$yIn == xy ]
          then
            cd `pwd`/submissions
            mv $others ../submissions.graded/$USER
        fi
        cd ..
    fi
fi


pkill -s 0 java

