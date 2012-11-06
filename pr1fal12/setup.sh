#!/bin/bash

umask 007

if [ -e reports/setup.sh.DONE.$USER ]
then
exit
fi

if [ x$USER == xsdc ]
then
  if [ ! -d reports ]
  then
  mkdir reports
  fi
  if [ ! -d submissions ]
  then
  mkdir submissions
  fi

  if [ ! -d submissions.graded ]
  then
    mkdir submissions.graded
  fi

  chmod 770 submissions submissions.graded submissions/*
  chgrp grade201 submissions submissions.graded submissions/*
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
chgrp grade201 reports/setup.sh.DONE.$USER

