#!/bin/bash

names=("z80ccf"
       "z80docflags"
       "z80doc"
       "z80flags"
       "z80full"
       "z80memptr"
      )

FILES="../z80.v ./tb.v ./ram.v"

runsim () {
	TESTFILE=$1
	LOGFILE=$2
	WORKDIR=$3
	
	echo
	echo
	echo ===========================
	echo TESTFILE $TESTFILE
	echo LOGFILE  $LOGFILE
	echo WORKDIR  $WORKDIR

	rm -rf $WORKDIR
	rm -f $LOGFILE

	vlib $WORKDIR

	vlog +define+TESTFILE=\"$TESTFILE\" +define+LOGFILE=\"$LOGFILE\" -work $WORKDIR -vopt -O5 -sv $FILES
	vsim -c -vopt $WORKDIR.tb -do 'run -all'
}



for n in "${names[@]}"
do
	TESTFILE="${n}.out"
	LOGFILE="${n}.log"
	WORKDIR="${n}_work"

	runsim $TESTFILE $LOGFILE $WORKDIR &

done

