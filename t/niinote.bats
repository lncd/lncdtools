#!/usr/bin/env bats

# setup temporary folder
setup() {
   export PATH="$BATS_TEST_DIRNAME:$PATH"
   THISTESTDIR=$(mktemp -d $BATS_TMPDIR/XXX)
   cd $THISTESTDIR
   return 0
}

teardown() {
   cd $BATS_TMPDIR
   [ -d "$THISTESTDIR" ] && rm -r $THISTESTDIR
   return 0
}

testnote(){
  [ -r "$1" ]
  output=$(3dNotes "$1" 2>/dev/null)
  [[ "$output" =~ "fakenii.py"  ]]
}

@test niinote-noarg-usage {
  run niinote
  [ $status -eq 1 ]
  [[ "$output" =~ USAGE ]]
}
@test niinote {
  niinote test.nii.gz fakenii.py test.nii.gz
  testnote test.nii.gz
}
@test niinote_quote {
  niinote "test.nii.gz" fakenii.py "test.nii.gz"
  testnote "test.nii.gz"
}

@test niinote_space_escape {
  niinote test\ 1.nii.gz fakenii.py test\ 1.nii.gz
  testnote test\ 1.nii.gz
}
@test niinote_space_quote {
  niinote "test 1.nii.gz" fakenii.py "test 1.nii.gz"
  testnote "test 1.nii.gz"
}

@test niinote_space_file_quote {
  mkdir "a b"
  niinote "a b/test 1.nii.gz" fakenii.py a\ b/"test 1.nii.gz"
  testnote "a b/test 1.nii.gz"
}
