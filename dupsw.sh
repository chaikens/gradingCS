#!/bin/bash

if [ ! -d $1  -o  ! -d $2 ]
then
echo "Invoke with two directories existing directories, source and destination"
exit
fi

graderGroup=grade201

chgrp $graderGroup $2

CPLIST="ArchiveAdapter.pm \
        SubmissionAdapter.pm \
        bash-readline-settings \
        directorize.pl \
        drjava \
        getOtherSubmissions.pl \
        import.sh \
        run.sh \
        scriptIG.pl \
        setup.sh "

MKDIRLIST=GradingCases

CUSTOMIZELIST="scriptIG.pl"


for fname in $CPLIST 
do
cp --preserve=mode,ownership --no-clobber --verbose $1/$fname $2/$fname
done

for fname in $MKDIRLIST 
do
mkdir -m 775 $2/$fname
chgrp $graderGroup $2/$fname
done


fname=GradingCases/gradersBuilder
cp --preserve=mode,ownership --no-clobber --verbose $1/$fname $2/$fname
