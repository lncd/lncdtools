#!/usr/bin/env bash
setup(){
  mkdir -p $BATS_TMPDIR/maskvolume-test
  cd $BATS_TMPDIR/maskvolume-test
  3dUndump \
      -dimen 4 4 4 -ijk -cubes -srad 1 -prefix 1.nii.gz -overwrite \
      <(echo -e "0 0 0 1\n3 3 3 2")

}
teardown(){
 cd
 rm -r $BATS_TMPDIR/maskvolume-test
}

maskvolume_default() { # @test
 run maskvolume  /tmp/1.nii.gz
 [[ $output =~ "1	8" ]]
 [[ $output =~ "2	27" ]]
}
maskvolume_nzmean() { # @test
 run maskvolume -nzmean /tmp/1.nii.gz
 [[ $output =~ "1	1 " ]]
 [[ $output =~ '2	2'$ ]]
}
