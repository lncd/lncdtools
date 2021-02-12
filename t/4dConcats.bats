#!/usr/bin/env bats

teardown() {
for rmfile in $BATS_TMPDIR/{junk{1,2,}.nii.gz,dt.txt}; do
 test -r "$rmfile" && rm "$rmfile" || :
done
}

@test noargs_justopts {
  run 4dConcatSubBriks -p 'patt*'
  [[ "$output" =~ "need output and glob arguments. see -h" ]]
}

@test concatsub_pattern {
  out=$BATS_TMPDIR/junk.nii.gz 
  test -r $out && rm $out
  3dUndump -dimen 2 2 2 -ijk  -prefix $BATS_TMPDIR/junk1.nii.gz -overwrite <(echo 0 0 0 1)
  3dUndump -dimen 2 2 2 -ijk  -prefix $BATS_TMPDIR/junk2.nii.gz -overwrite <(echo 0 0 0 2)
  4dConcatSubBriks -p 'junk[12]' $out  "$BATS_TMPDIR/"'junk*'
  [ -r $out ]
  labels=$(3dinfo -label $out)
  echo "labels: '$labels' should be junk1|junk2"
  [ $labels == "junk1|junk2" ]
}

@test dt_run1 {
  test -r $BATS_TMPDIR/junk.nii.gz && rm $BATS_TMPDIR/junk.nii.gz
  3dUndump -dimen 2 2 2 -ijk  -prefix $BATS_TMPDIR/junk1.nii.gz -overwrite <(echo 0 0 0 1)
  3dUndump -dimen 2 2 2 -ijk  -prefix $BATS_TMPDIR/junk2.nii.gz -overwrite <(echo 0 0 0 2)
  echo -e "Subj\tjunk\tInputFile\nfoo\ta\t$BATS_TMPDIR/junk1.nii.gz[0]\nbar\ta\t$BATS_TMPDIR/junk2.nii.gz[0]" > $BATS_TMPDIR/dt.txt

  run 4dConcatDataTable $BATS_TMPDIR/junk.nii.gz  $BATS_TMPDIR/dt.txt 
  [ $status == 0 ]
  [ -r $BATS_TMPDIR/junk.nii.gz ]
  [ $(3dinfo -label $BATS_TMPDIR/junk.nii.gz) == "foo|bar" ]
}
@test dt_extraid {
  test -r $BATS_TMPDIR/junk.nii.gz && rm $BATS_TMPDIR/junk.nii.gz
  3dUndump -dimen 2 2 2 -ijk  -prefix $BATS_TMPDIR/junk1.nii.gz -overwrite <(echo 0 0 0 1)
  3dUndump -dimen 2 2 2 -ijk  -prefix $BATS_TMPDIR/junk2.nii.gz -overwrite <(echo 0 0 0 2)
  echo -e "Subj\textracol\tInputFile\nfoo\ta\t$BATS_TMPDIR/junk1.nii.gz[0]\nbar\tb\t$BATS_TMPDIR/junk2.nii.gz[0]" > $BATS_TMPDIR/dt.txt

  run 4dConcatDataTable $BATS_TMPDIR/junk.nii.gz $BATS_TMPDIR/dt.txt extracol
  [ $status == 0 ]
  [ -r $BATS_TMPDIR/junk.nii.gz ]
  [ $(3dinfo -label $BATS_TMPDIR/junk.nii.gz) == "foo_a|bar_b" ]
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

