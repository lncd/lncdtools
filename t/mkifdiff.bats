#!/usr/bin/env bats
 
export DATE="2009-01-30"
export MKIFDIFFFILE=$BATS_TMPDIR/bats_mkifdiff.test
export MKIFDIFFFILE_DNE=$BATS_TMPDIR/bats_mkifdiff_dne.test
setup(){
  echo $DATE > $MKIFDIFFFILE
  touch -d $DATE $MKIFDIFFFILE
}
teardown(){
 [ -n "$MKIFDIFFFILE" -a -r "$MKIFDIFFFILE" ] && rm "$MKIFDIFFFILE" || :
 test -n "$MKIFDIFFFILE_DNE" -a -r "$MKIFDIFFFILE_DNE"  && rm "$MKIFDIFFFILE_DNE" || :
 return 0
}

batmsg(){ echo "$*"|sed 's/: /:\t/' >&2; }
modtime_unchanged() {
  mod_date="$(stat -c"%.10y" $MKIFDIFFFILE)"
  batmsg forceddate: $DATE
  batmsg filemod: $mod_date
  [[ "$mod_date" =~ ^$DATE ]]
}

@test same_not_modified {
  output=$(echo $DATE | mkifdiff $MKIFDIFFFILE)
  modtime_unchanged
  batmsg file: $MKIFDIFFFILE
  [[ "$output" =~ "has not changed" ]]
}

@test modified {
  newdate="$(date)"
  echo "$newdate" | mkifdiff $MKIFDIFFFILE
  filedate=$(cat $MKIFDIFFFILE)
  batmsg filedate: "'$filedate'"
  batmsg newdate: "'$newdate'"
  ! modtime_unchanged
  [ "$filedate" = "$newdate" ]
  return 0
}

@test dne {
  [ -r "$MKIFDIFFFILE_DNE" ] && rm "$MKIFDIFFFILE_DNE"
  newdate=$(date)
  output=$(echo -n "$newdate" | mkifdiff $MKIFDIFFFILE_DNE)
  batmsg newdate: $newdate
  batmsg output: $output
  batmsg $MKIFDIFFFILE_DNE: $(cat $MKIFDIFFFILE_DNE)
  [ -r "$MKIFDIFFFILE_DNE" ]
  [[ "$(cat $MKIFDIFFFILE_DNE)" == "$newdate" ]]
  [[ "$output" =~ "creating" ]]
}

@test fail_on_empty {
  echo -n | mkifdiff -n $MKIFDIFFFILE  || :
  [[ "$(cat $MKIFDIFFFILE)" == "$DATE" ]]

  echo -n | mkifdiff $MKIFDIFFFILE
  [[ ! -s $MKIFDIFFFILE ]]
}
