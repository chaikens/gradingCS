#! /bin/bash  --verbose

killall scriptIG.pl

export TANAME=chaikens

PATH=$PATH:.  #Old fashioned setting.

./scriptIG.pl `pwd`/../submissions/student.2012-03-03-04-57-02
./scriptIG.pl `pwd`/../submissions/multMain.2012-03-03-04-57-02
./scriptIG.pl `pwd`/../submissions/nullCrash.2012-03-03-04-57-02

