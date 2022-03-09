#!/usr/bin/env bats
 
DATE="2010-01-30"
MKIFDIFFFILE=/tmp/bats_mkifdiff.test
MKIFDIFFFILE_DNE=/tmp/bats_mkifdiff_dne.test
setup(){
  echo $DATE > $MKIFDIFFFILE
  touch -d $DATE $MKIFDIFFFILE
}
teardown(){
 [ -n "$MKIFDIFFFILE" -a -r "$MKIFDIFFFILE" ] && rm "$MKIFDIFFFILE"
 test -n "$MKIFDIFFFILE_DNE" -a -r "$MKIFDIFFFILE_DNE"  && rm "$_" || :
}


@test same_not_modified {
  output=$(echo $DATE | mkifdiff $MKIFDIFFFILE)
  [[ "$(stat -c"%y" $MKIFDIFFFILE)" =~ ^$DATE ]]
  [[ "$output" =~ "has not changed" ]]
}

@test modified {
  newdate=$(date)
  echo $newdate | mkifdiff $MKIFDIFFFILE
  ! [[ "$(stat -c"%y" $MKIFDIFFFILE)" =~ ^$DATE ]]
  [[ "$(cat $MKIFDIFFFILE)" == "$newdate" ]]
}

@test dne {
  newdate=$(date)
  output=$(echo -n "$newdate" | mkifdiff $MKIFDIFFFILE_DNE)
  [ -r "$MKIFDIFFFILE_DNE" ]
  [[ "$(cat $MKIFDIFFFILE_DNE)" == "$newdate" ]]
  [[ "$output" =~ "creating" ]]
}
