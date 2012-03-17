#! /bin/bash  --verbose

killall scriptIG.pl

export TANAME=chaikens
mkdir 201grading
mkdir 201grading/private
mkdir 201grading/private/pr2
mkdir 201grading/pr2
mkdir 201grading/pr2/GradingCases
touch 201grading/pr2/GradingCases/penalties

PATH=$PATH:.  #Old fashioned setting.

./scriptIG.pl `pwd`/submissions/student.2012-03-03-04-57-02

