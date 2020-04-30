#!/usr/bin/env bats

@test dt_run1 {
  test -r $BATS_TMPDIR/junk.nii.gz && rm $_
  3dUndump -dimen 2 2 2 -ijk  -prefix $BATS_TMPDIR/junk1.nii.gz -overwrite <(echo 0 0 0 1)
  3dUndump -dimen 2 2 2 -ijk  -prefix $BATS_TMPDIR/junk2.nii.gz -overwrite <(echo 0 0 0 1)
  echo -e "Subj\tjunk\tInputFile\nfoo\ta\t$BATS_TMPDIR/junk1.nii.gz[0]\nbar\ta\t$BATS_TMPDIR/junk2.nii.gz[0]" > $BATS_TMPDIR/dt.txt

  run 4dConcatDataTable $BATS_TMPDIR/junk.nii.gz  $BATS_TMPDIR/dt.txt 
  [ $status == 0 ]
  [ -r $BATS_TMPDIR/junk.nii.gz ]
  [ $(3dinfo -label $BATS_TMPDIR/junk.nii.gz) == "foo|bar" ]
}
@test badprefix_subbricks {
  run 4dConcatSubBriks xxx 'glob*'
  [[ "$output" =~ "must end" ]]
}
@test badprefix_datatable {
  run 4dConcatDataTable xxx 'file'
  echo "$output" >&2
  [[ "$output" =~ "must end" ]]
}

