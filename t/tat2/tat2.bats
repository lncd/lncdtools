#!/usr/bin/env bats
setup(){
mkdir -p $BATS_TMPDIR/tat2-test
cd $BATS_TMPDIR/tat2-test
echo "
   0 0 0 1
   0 1 0 1
   1 0 0 2
   1 1 0 1
" > 1.1d
echo "
   0 0 0 1
   0 1 0 2
   1 0 0 2
   1 1 0 100
" > 2.1d
   3dUndump -dimen 2 2 2 -ijk  -prefix 1.nii.gz -overwrite 1.1d
   3dUndump -dimen 2 2 2 -ijk  -prefix 2.nii.gz -overwrite 2.1d

   3dcalc -a 1.nii.gz -expr 'step(a)' -prefix m.nii.gz -overwrite
   3dTcat -prefix t.nii.gz 1.nii.gz 2.nii.gz 1.nii.gz -overwrite
   echo -e "1\n0\n1" > c.1D
}
teardown(){
 cd
 rm -r $BATS_TMPDIR/tat2-test
}

@test sametwice {
   tat2 t.nii.gz -median -output med1.nii.gz -mask m.nii.gz
   tat2 t.nii.gz -median -output med2.nii.gz -mask m.nii.gz
   [ $(3dBrickStat med1.nii.gz) == $(3dBrickStat med2.nii.gz) ]
}

@test med_gt_mean {
   # large outlier drives mean (denominator) way up. mean should be smaller than med
   tat2 t.nii.gz -output mean.nii.gz -mask m.nii.gz
   tat2 t.nii.gz -median -output med.nii.gz -mask m.nii.gz
   # mean=701.587 median=8416.67
   mdgtmn=$(echo "[1p]sr $(3dBrickStat mean.nii.gz) $(3dBrickStat med.nii.gz) >r"|dc)
   [ "x$mdgtmn" == "x1" ]
}

@test cen {
   # censor does not have large include large (100) value
   #  censor < mean
   tat2 t.nii.gz -output mean.nii.gz -mask m.nii.gz 
   tat2 t.nii.gz -output cen.nii.gz -mask m.nii.gz -censor_rel c.1D
   3dNotes cen.nii.gz |grep -q keep2
   cnltmn=$(echo "[1p]sr $(3dBrickStat mean.nii.gz) $(3dBrickStat cen.nii.gz) <r"|dc)
   [ "x$cnltmn" == "x1" ]
}
