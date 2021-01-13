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
   rm -r $THISTESTDIR
   return 0
}

@test rename_abc {
  touch abc.nii.gz
  rename-recent 's/b/xx/' ./ 'abc*'
  [ -f axxc.nii.gz ]
  [ ! -f abc.nii.gz ]
}

@test norename-old {
  touch -d "2 days ago" abc.nii.gz
  rename-recent s/b/xx/ ./ 'abc*'
  [ ! -f axxc.nii.gz ]
  [ -f abc.nii.gz ]
}

@test dryrun-env {
  touch abc.nii.gz
  DRYRUN=1 rename-recent 's/b/xx/' ./ 'abc*'
  [ ! -f axxc.nii.gz ]
  [ -f abc.nii.gz ]
}
@test dryrun-arg {
  touch abc.nii.gz
  DRYRUN=1 rename-recent 's/b/xx/' ./ 'abc*' -n
  [ ! -f axxc.nii.gz ]
  [ -f abc.nii.gz ]
}
