@test test_skiphead {
   echo -e 'a\nb' > $BATS_TEST_TMPDIR/ab.txt
   echo -e 'c\nd' > $BATS_TEST_TMPDIR/cd.txt
   o=$(cat_skiphead $BATS_TEST_TMPDIR/{ab,cd}.txt | paste -sd,)
   [[ $o == "a,b,d" ]]
   
   o=$(cat_skiphead $BATS_TEST_TMPDIR/{cd,ab}.txt | paste -sd,)
   [[ $o == "c,d,b" ]]
}
