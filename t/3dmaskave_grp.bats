#!/usr/bin/env bats

setup() { 
   source 3dmaskave_grp
   3dUndump -overwrite -dimen 2 2 2 -ijk  -prefix $BATS_TEST_TMPDIR//roi1.nii.gz -overwrite <(echo 0 0 0 1)
   3dcalc -overwrite -prefix $BATS_TEST_TMPDIR/data.nii.gz -expr 'step(a+1)' -a $BATS_TEST_TMPDIR/roi1.nii.gz
}
function test_roistats_header_opts { # @test
 run roistats_header_opts -nomeanout -nzvoxels 
 [[ $output == "nzvoxels" ]]

 run roistats_header_opts -nomeanout -nzvoxels -nzmean
 [[ $output == "nzvoxels,nzmean" ]]

 run roistats_header_opts
 [[ $output == "mean" ]]

 run roistats_header_opts -nzvoxels -nzmean
 [[ $output == "mean,nzvoxels,nzmean" ]]
}
function test_repna_roistats_opts { # @test
 run repna_roistats_opts -nomeanout -nzvoxels 
 echo "output: $output" >&2
 [[ $output == "NA" ]]

 run repna_roistats_opts -nomeanout -nzvoxels -nzmean
 [[ $output == "NA,NA" ]]

 run repna_roistats_opts
 [[ $output == "NA" ]]

 run repna_roistats_opts -nzvoxels -nzmean
 [[ $output == "NA,NA,NA" ]]
}

function test_roistats_NA { # @test
 run roistats_NA $BATS_TEST_TMPDIR/roi1.nii.gz $BATS_TEST_TMPDIR/data.nii.gz
 echo "output: $output"
 [[ $output  == "1.000000,1" ]]
}

function test_roistats { # @test
 run 3dmaskave_grp \
    -roistats 1 -pattern data -csv $BATS_TEST_TMPDIR/test.csv \
   -m roi1=$BATS_TEST_TMPDIR/roi1.nii.gz'<1>'\
   -m roi2=$BATS_TEST_TMPDIR/roi1.nii.gz -- $BATS_TEST_TMPDIR/data.nii.gz
 [[ $status -eq 0 ]]
 run tail -n1 $BATS_TEST_TMPDIR/test.csv
 [[ "$output"  == "roi2,data,data,1.000000,1" ]]
}
function test_roistats_args { # @test
 run 3dmaskave_grp \
    -roistats -nzmean,-nzvoxels,-nzsigma -pattern data -csv $BATS_TEST_TMPDIR/test.csv \
   -m roi1=$BATS_TEST_TMPDIR/roi1.nii.gz -- $BATS_TEST_TMPDIR/data.nii.gz
 [[ $status -eq 0 ]]
 run sed 1q $BATS_TEST_TMPDIR/test.csv
 [[ "${output}" =~ "roi,subj,input,mean,nzmean,nzvoxels,nzsigma" ]]
 run tail -n1 $BATS_TEST_TMPDIR/test.csv
 [[ "${output}" =~ "roi1,data,data,1.000000,1.000000,1,1000000" ]]
}

function test_maskave { # @test
 run 3dmaskave_grp \
   -pattern data -csv $BATS_TEST_TMPDIR/test.csv \
   -m roi1=$BATS_TEST_TMPDIR/roi1.nii.gz'<1>'\
   -m roi2=$BATS_TEST_TMPDIR/roi1.nii.gz -- /tmp/data.nii.gz
 [[ $status -eq 0 ]]
 run tail -n1 $BATS_TEST_TMPDIR/test.csv
 [[ "$output"  == "roi2,data,data,1" ]]
}
