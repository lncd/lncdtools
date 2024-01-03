setup() {
   ROOT=$PWD;
   THISTESTDIR=$(mktemp -d $BATS_TMPDIR/id-12345_XXX)
   t/mkdcm.py $THISTESTDIR/001.dcm '1,2;3,4'
   cd $THISTESTDIR
   return 0
}

teardown() {
   cd $BATS_TMPDIR
   [ -d "$THISTESTDIR" ] && rm -r "$THISTESTDIR"
   return 0
}


@test dcmdirtab-singledirectory {
  run dcmdirtab -s 'id-\d{5}' -d $(pwd)
  [ $status -eq 0 ]
  [[ $output =~ "id-12345	" ]]
  [[ $output =~ "	2000.0	" ]]
}

@test dcmdirtab-help {
  run $ROOT/dcmdirtab --help
  [ $status -eq 0 ]
  [[ $output =~ "SETUP" ]]
}

@test dcmdirtab-help-badargs {
  run dcmdirtab -h
  [ $status -ne 0 ]
  [[ ! $output =~ "SETUP" ]]
}
@test dcmdirtab-with-custom-dcm-suffix {
  cd $THISTESTDIR
  mv 001.dcm 'Image (001)'
  run dcmdirtab -s 'id-\d{5}' -p '.*Image.*' -d $(pwd)
  [ $status -eq 0 ]
  [[ $output =~ "id-12345	" ]]
  [[ $output =~ "	2000.0	" ]]
}

