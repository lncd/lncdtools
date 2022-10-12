#include <stdio.h>
int main(int argc, char *argv[]) {
   for(int i=1; i < argc;  i++){
      fprintf(stderr, "%s", argv[i]);
      if(i<argc-1) fprintf(stderr, " ");
   }
   fprintf(stderr, "\n");
   return 0;
}

/*
 why c?
 because it's easy enough to code :)
 binary is 5x larger (20K) and only runs 2-4x as fast as dash/bash (echo "$@" >2) or perl
 warning is unlikely to ever be the tight loop performace bottleneck.
 so this just for fun


hyperfine -N --export-csv >(cat) warn test me
  Time (mean ± σ):       1.3 ms ±   0.2 ms    [User: 0.8 ms, System: 0.4 ms]
  Range (min … max):     1.1 ms …   3.4 ms    1676 runs
hyperfine -N --export-csv >(cat) warn.dash test me
  Time (mean ± σ):       2.4 ms ±   0.3 ms    [User: 1.0 ms, System: 1.2 ms]
  Range (min … max):     2.1 ms …   5.7 ms    953 runs
hyperfine -N --export-csv >(cat) warn.pl test me # print STDERR "@ARGV\n";
  Time (mean ± σ):       2.8 ms ±   0.3 ms    [User: 1.3 ms, System: 1.3 ms]
  Range (min … max):     2.5 ms …   5.8 ms    601 runs
hyperfine -N --export-csv >(cat) warn.bash test me 
  Time (mean ± σ):       5.1 ms ±   0.8 ms    [User: 2.8 ms, System: 2.1 ms]
  Range (min … max):     4.5 ms …  10.2 ms    523 runs
 

command   ,mean                ,stddev              ,median     ,user                 ,system,min,max
warn     ,0.0012507016527446308,0.000219916101220486,0.001201705,0.0007765029832935562,0.0003650011933174228,0.00106886,0.00343389
warn.dash,0.0024232519223504763,0.000342939673951839,0.002344727,0.0010063567681007338,0.001242098635886673,0.002070156,0.005659354
warn.bash,0.005108132988527722,0.0007640626443461939,0.004898110000000001,0.0028141108986615678,0.002057764818355641,0.004495664,0.01020713
warn.pl  ,0.0028228331098169713,0.0003460886393552879,0.0027432650000000004,0.001313840266222962,0.0013080066555740425,0.002519842,0.005833629000000001


*/
