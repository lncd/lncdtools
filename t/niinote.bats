#!/usr/bin/env bats

# setup temporary folder
setup() {
   THISTESTDIR=$(mktemp -d $BATS_TMPDIR/XXX)
   cd $THISTESTDIR
   cat >asciimg <<H
2 1 
1 1 

0 0 
0 0 

H

   return 0
}

teardown() {
   cd $BATS_TMPDIR
   rm -r $THISTESTDIR
   return 0
}

testnote(){
  [ -r "$1" ]
  output=$(3dNotes "$1" 2>/dev/null)
  [[ "$output" =~ "fslascii2img"  ]]
}

@test niinote {
  niinote test.nii.gz fslascii2img asciimg 2 2 2 1 1 1 1 1 test.nii.gz
  testnote test.nii.gz
}
@test niinote_quote {
  niinote "test.nii.gz" fslascii2img asciimg 2 2 2 1 1 1 1 1 "test.nii.gz"
  testnote "test.nii.gz"
}

@test niinote_space_escape {
  niinote test\ 1.nii.gz fslascii2img asciimg 2 2 2 1 1 1 1 1 test\ 1.nii.gz
  testnote test\ 1.nii.gz
}
@test niinote_space_quote {
  niinote "test 1.nii.gz" fslascii2img asciimg 2 2 2 1 1 1 1 1 "test 1.nii.gz"
  testnote "test 1.nii.gz"
}

@test niinote_space_file_quote {
  mkdir "a b"
  niinote "a b/test 1.nii.gz" fslascii2img asciimg 2 2 2 1 1 1 1 1 a\ b/"test 1.nii.gz"
  testnote "a b/test 1.nii.gz"
}
