#!/usr/bin/env Rscript

#
# Usage: get_ld8_age.R 11543_20180626 11570_20180615
#
# outputs tab delmin table with age and sex (+ dob)
# ld8 age   sex   dob
# 11543_20180626 16.06 M  2002-06-03
# 11570_20180615 20.39 F  1998-01-23
# 
# N.B. merge is likely to resort from input order
# if bad date or unfound luna, will spit out "NA"
#

suppressMessages(library(dplyr))

ld8info <- function(ld8_vec, want_ses=FALSE) {
# better called age_table_from_ld8
# fetch age sex and dob from vector of lunaid_yyyymmdd
# strings
   d <- data.frame(ld8=ld8_vec) %>%
    tidyr::separate(sep="_", ld8, c("id", "ymd"), remove=F) %>%
    mutate(vdate=lubridate::ymd(ymd))

   # input into sql approprate string. eg " '11523','10931' "
   l_in <-
      d$id %>%
      gsub("[^0-9A-Za-z]", "", .) %>% # sanatize
      gsub("^", "'", .) %>%           # add begin quote
      gsub("$", "'", .) %>%           # add ending quote
      paste(collapse=",")             # put commas between

   query <- sprintf("
             select *
             from person
             natural join enroll
             where id in (%s)", l_in)

   r <- LNCDR::db_query(query)
   f <-
      merge(r, d, by="id", all=T) %>%
      mutate(age=round(as.numeric(vdate-dob)/365.25, 2)) %>%
      select(ld8, age, sex, dob)

   if(want_ses) {
    session <- LNCDR::db_query(
   "select
      id || '_' || to_char(vtimestamp, 'YYYYMMDD') as ld8,
      visitno as session 
    from visit v
    join enroll e on e.pid=v.pid and e.etype = 'LunaID'")
    f <- merge(f, session, by="ld8", all.x=T)
   }

   return(f)
}

ld8info_main <- function() {
   # spit out results
   input_args <- commandArgs(trailingOnly=T)
   want_ses <- FALSE
   # TODO:
   # USAGE if no args or -help
   # 
   if(first(input_args) == "-ses") {
      input_args <- input_args[-1]
      want_ses <- TRUE
   }
   f <- ld8info(input_args, want_ses)
   write.table(f, file=stdout(), row.names=F, sep="\t", quote=F)
}

# run if not sourced
if(sys.nframe()==0) ld8info_main()
