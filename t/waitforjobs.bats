export SLEEPTIME=1s # quick polling. default is 60s

#NB. can't use 'run' or 'timeout'.
#otherwise waitforjobs parent is not where the sleeps are
#
# can wrap in a function. works with run to capture $output
# but timeout still wont work (even with export -f capture_waitforjobs)
capture_waitforjobs(){
 n=$1; t=$2; j=$3
 for i in $(seq 1 $n); do 
    sleep $t &
 done
 waitforjobs -j $j
}

test_afterhours { # @test
   source waitforjobs
   run is_after_hours 07
   [ $status -eq 0 ]

   run is_after_hours 23
   [ $status -eq 0 ]

   run is_after_hours 10
   [ $status -eq 1 ]

   run is_after_hours 16
   [ $status -eq 1 ]
}
function test_nowaiting { # @test
  sleep 3 &
  tic=$(date +%s)
  jobs
  waitforjobs -j 2
  toc=$(date +%s)

  dur=$(($toc - $tic))
  warn "$toc - $tic = $dur"
  [[ $dur -le 1 ]]
}

function test_waitforjobs { # @test
  sleep 2 &
  sleep 2 &
  sleep 2 &
  tic=$(date +%s)
  waitforjobs -j 2
  toc=$(date +%s)
  dur=$(($toc - $tic))
  warn "$toc - $tic = $dur"
  [[ $dur -le 3 ]]
}

function test_waitforjobsoutput { # @test
  tic=$(date +%s)
  run capture_waitforjobs 3 2s 2
  toc=$(date +%s)
  dur=$(($toc - $tic))
  warn "$tic $toc=$dur: $output"
  [[ $output =~ "sleep" ]]
  [[ ! $output =~ "waitforjobs" ]]
  [[ $dur -eq 2 ]]
}

function test_fail_config { # @test
  run waitforjobs -j 3 -c /I/dont/exist.jobcfg
  [ $status -eq 2 ]
}

function test_config { # @test
  #sleep 2 &
  #sleep 2 &
  #sleep 2 &
  TMPDIR=$BATS_TEST_TMPDIR run waitforjobs -s .5 -j 2 -c auto
  f=$(ls $BATS_TEST_TMPDIR/${HOSTNAME:-NOHOST}-${USER:-NOUSER}-*.jobcfg)
  [ -n "$f" -a -r "$f" ]
  grep maxjobs=2 "$f"
  grep sleeptime=.5 "$f"

  #echo "output: '$output'" >&2
  #[[ $output =~ sleep ]]
}
