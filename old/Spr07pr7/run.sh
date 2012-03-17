#! /bin/bash  --verbose

killall scriptIG.pl

export TANAME=chaikens
mkdir acsi310
mkdir acsi310/private
mkdir acsi310/private/pr7
mkdir acsi310/pr7
mkdir acsi310/pr7/GradingCases
touch acsi310/pr7/GradingCases/penalties

PATH=$PATH:.  #Old fashioned setting.

./scriptIG.pl `pwd`/submissions/student.2012-03-03-04-57-02

