#!/usr/bin/env bats

# get mkdcm.py
# setup temporary folder
setup() {
   export PATH="$BATS_TEST_DIRNAME:$PATH"
   THISTESTDIR=$(mktemp -d $BATS_TMPDIR/XXX)
   cd $THISTESTDIR
   return 0
}
teardown() {
   cd $BATS_TMPDIR
   rm -r $THISTESTDIR
   return 0
}

@test mknii samedir {
  mkdcm.py "test.dcm" 
  mknii test.nii.gz test.dcm 
  [ -r test.nii.gz ]
}
@test mknii mkdir {
  mkdcm.py "test.dcm" 
  mknii sub-1/ses-1/junk/test.nii.gz test.dcm 
  [ -r sub-1/ses-1/junk/test.nii.gz ]
}
@test mknii dcm_quotespaces {
  mkdir "spa ce"
  mkdcm.py "spa ce/test.dcm" 
  mknii sub-1/ses-1/junk/test.nii.gz "spa ce/test.dcm"
  [ -r sub-1/ses-1/junk/test.nii.gz ]
}
@test mknii dcm_escapespace {
  mkdir "spa ce"
  mkdcm.py "spa ce/test.dcm" 
  mknii sub-1/ses-1/junk/test.nii.gz sp*\ ce/test.dcm
  [ -r sub-1/ses-1/junk/test.nii.gz ]
}
@test mknii nii_space {
  mkdcm.py test.dcm
  mknii sub-1/ses\ 1/junk/test.nii.gz test.dcm
  [ -r sub-1/ses\ 1/junk/test.nii.gz ]

  mknii "sub-1/ses 1/junk/test.nii.gz" test.dcm
  [ -r sub-1/ses\ 1/junk/test.nii.gz ]
}
