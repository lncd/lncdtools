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
