#!/usr/bin/env bash
set -euo pipefail

# LOG:
#  20190828WF  init
#  20191002WF perldoc

# heredoc for perldoc documentation
<<'perldoc'
=pod

=head1 NAME

roi2 - reimplement data science toolkit's Rio with more shortcuts and magic a la 'perl -e'

perfect for quick write-only one liner data exploration

=head1 SYNOPSIS

cat data | rio2 'r commands'

=head2 Magic Example

use of specific aliases imply other code. Specificly:
C<d> is read from data from stdin unless C<rt()> or C<rt()> are used to read in a file
C<p()> implies loading C<ggplot> and will wait for X11 window to close

   
   echo -e '1\n2' | rio2 "m(d,x=V1+1)%>%p()+a(x,V1)+gp()"


=head2 Less Magic

   echo -e '1\tdesc field\n2\tdesc' | rio2 "rt(sep='\t') %>% m(x=V1+1)%>%p()+a(V2,V1)+gp()" 

=head2 Practical Example

  for f in /Volumes/Zeus/preproc/petrest_rac1/brnsuwdktm_rest/99998_20190*/tsnr/*txt; do echo $f $(cat $f); done |egrep -v 'usan_size|noise'| 
   rio2 'r(f=V1, tsnr=V2) %>%
         m(id=e(f,ld8),
           prefix=e(f,"(?<=[0-9]-)([^._]*)"),
           step=str_length(prefix),
           name=p0(sf("%02d",step),"_",prefix)) %>%
         p() + a(x=name,y=tsnr,color=id,group=id) + gp() + geom_path()'

=head2  ALIASES 

  ld8 is luna_date pattern "\\d{5}_\\d{8}"
  e() is str_extract
  l() is library
  p() is ggplot2 optionally using magic d
  a(),gl(),gp() are ggplot2::aes, geom_line, and geom_points
  m(), g(), s() are dplyr::mutate, group_by, and summarize
  ac(), an() is as.character, as.numeric
  ra() (rename all) is set_colnames on magic 'd'
  r() is rename
  rt() is read.table with stdin, when run populates 'd'
  rc() is read.csv with stdin, when called popultes 'd'
  p0() is paste0
  pd() is print dataframe wihtout row numbers and no max
  sf() is sprintf


=head1 TODO

  * run with `R` and b() as browser() 
  * tr '\n' ';' and kill stand alone ';' that would cause error

=cut
perldoc

[ $# -eq 0 ] && perldoc $0 && exit 1

ALIAS='
p<-function(data=d,...) ggplot2::ggplot(data,...);
m<-dplyr::mutate; g<-dplyr::group_by; s<-dplyr::summarize;
ra<-function(...) d<<-magrittr::set_colnames(d,...);
r<-function(...) d<<-dplyr::rename(d,...);
e<-stringr::str_extract;
pd<-function(...) print.data.frame(d,row.names=F,max.rows=Inf,...);
rt<-function(...) d<<-read.table(file("stdin","r"),...);
rc<-function(...) d<<-read.csv(file("stdin","r"),...);
gl <- ggplot2::geom_line;
gp <- ggplot2::geom_point;
a <- ggplot2::aes;
l <- library;
ld8 <- "\\d{5}_\\d{8}";
sf <- sprintf;
p0 <- paste0;
an <- as.numeric;
ac <- as.character;
'
LIBS="library(stringr);library(dplyr);library(tidyr);"

# are we plotting with p?
if echo "$@" | grep '\<p(' >/dev/null; then
   LIBS="$LIBS library(ggplot2);library(cowplot);" 
   CMD="theme_set(theme_cowplot()); x11(); $@; while(length(dev.list())) Sys.sleep(1);" 
else
   CMD="$@"
fi

# if no call to rc or rt, call read.csv to make d
! echo "$@" | grep '\<r[ct](' >/dev/null && CMD="rt(); $CMD"

CMD="suppressPackageStartupMessages({$LIBS}); $ALIAS $CMD"
CMD="$(echo "${CMD}"|tr '\n' ' ')"
set -x
Rscript -e "$CMD"
