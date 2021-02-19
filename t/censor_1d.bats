#!/usr/bin/env bats
setup() {
  MYTEMP=$BATS_TMPDIR/censor_1d
  mkdir -p $MYTEMP
  cd $MYTEMP
  mkdir 1 2
  echo "0.1 0.5 0.7"|tr ' ' '\n' > 1/fd.txt
  FIRST_thres5="1 0 0"

  echo ".3 .1 0 1" |tr ' ' '\n' > 2/fd.txt
  SECOND_thres5="1 1 1 0"

  export MYTEMP SECOND_thres5 FIRST_thres5
}
teardown() {
  cd
  rm -r $MYTEMP
}

comp_to(){
  ls -R
  [ -r "$1" ]
  o="$(cat $1|tr '\n' ' ')"
  echo "$1: '$o' VS '$2 '"
  [  "$o" == "$2 " ]
}

@test dryrun {
  DRYRUN=1 censor_1d 2/fd.txt
  [ ! -r 2/fd_cen_0.5.1d ]
}

@test single {
  censor_1d 2/fd.txt
  ls 2/
  comp_to 2/fd_cen_0.5.1d "$SECOND_thres5"
}

@test single_prefix {
  censor_1d -prefix cen 2/fd.txt
  comp_to 2/cen_0.5.1d "$SECOND_thres5"
}

@test single_thres {
  censor_1d -thres 0 2/fd.txt
  [ -r 2/fd_cen_0.1d ]
  [ "$(cat 2/fd_cen_0.1d)" == "$(sed s/.*/0/ 2/fd.txt)" ]
}
@test single_colidx {
  echo -e "1 .2\n2 .3" > 1/fd.txt
  censor_1d -colidx 1 1/fd.txt
  comp_to 1/fd_cen_0.5.1d "1 1"
}

@test run_glob {
  censor_1d */fd.txt
  comp_to 1/fd_cen_0.5.1d "$FIRST_thres5"
  comp_to 2/fd_cen_0.5.1d "$SECOND_thres5"
}
