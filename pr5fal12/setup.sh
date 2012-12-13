#!/bin/bash


GR_GROUP="grade201"

umask 007

if [ -e reports/setup.sh.DONE.$USER ]
then
exit
fi

if [ x$USER == xsdc ]
then
  if [ ! -d reports ]
  then
  mkdir -m 770 reports
  fi
  if [ ! -d submissions ]
  then
  mkdir -m submissions
  fi

  if [ ! -d submissions.graded ]
  then
    mkdir -m 770 submissions.graded
  fi

  chmod 770 submissions reports submissions.graded submissions/*
  chgrp $GR_GROUP submissions reports submissions.graded submissions/*
fi

if [ ! -d reports/$USER ]
then
  mkdir reports/$USER
  touch reports/$USER.no_report
  touch reports/$USER.summary
fi
chmod 770 reports/$USER
chmod 660 reports/$USER.no_report reports/$USER.summary


if [ ! -d submissions.graded/$USER ]
then
  mkdir submissions.graded/$USER
fi
chmod 770 submissions.graded/$USER

touch reports/setup.sh.DONE.$USER
chgrp $GR_GROUP reports/setup.sh.DONE.$USER

