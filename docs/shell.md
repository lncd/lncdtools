# Shell Tools

Jump right into with an [example](#example-script).

## `dryrun`

`dryrun` runs a command only when the `$DRYRUN` environmental variable is not set. [^dryrun_name]

```shell title="dryrun'ed"
$ echo hi > myfile
$ export DRYRUN=1
$ dryrun rm myfile  
rm myfile  # (1)!
$ cat myfile
hi
```

1. this is printed but not run

```shell title="actually run"
$ echo hi > myfile
$ export DRYRUN=
$ dryrun rm myfile # (1)!
$ cat myfile
cat: myfile: No such file or directory
```

1. nothing is printed. `rm` runs silently as if `dryrun` was not there

It's worth noting bash allows environmental variables to be set and scoped to a single command by prefacing the call with `var=val`. For `dryrun` enabled scripts and functions, this means staring with `DRYRUN=1` for the "just print" version.

```shell title="compact"
$ example(){ dryrun rm myfile; }
$ DRYRUN=1 example
rm myfile # (1)!
$ echo $DRYRUN
# (2)!
```

1. `rm myfile` is printed but not run
2. empty line showing `$DRYRUN` is not set but was for the call above (where it was explicitly declared)

[^dryrun_name]: "dryrun"'s name is taken from the rsync "--dryrun" option. `perl-rename` alias `--dry-run` with `--just-print`

## `drytee`

`drytee` works like `dryrun` but for capturing output you may want to be written to a file unless `$DRYRUN` is set. It's like the command `tee` but for writing to standard error when the user wants a dry run.

```shell
$ echo hi | drytee myfile
$ cat myfile
hi # (1)!
$ DRYRUN=1
$ echo bye | drytee myfile
#       bye
# would be written to myfile
$ cat myfile
hi # (2)!
```

1. `myfile` was written ("hi") b/c `DRYRUN` is not set
2. `myfile` is unchanged. `bye` was not written

## `warn`

`warn` could be written `echo "$@" > &2`. It simply writes it's arguments to standard error (2) instead of standard output. This is useful to avoid shell capture to either a variable or a file.
```shell title="avoid capture"
$ a=$(warn "oh no"; echo "results")
oh no # (1)!
$ echo $a
results
```

1. 'oh no' seen on the terminal b/c it's written to stderr. "resutls" on stdout is captured into `$a`

A contrived example for giving a warning that doesn't end up in the output (but still potentially notifies the user)
```shell title="no warning in file"
# create a file of n lines sequentally numbered
filelines(){
  n="$1"
  [ $n -lt 2 ] && warn "# WARNING: n=$n < 2. limited output"
  printf "%s\n" $(seq 1 $n)
}
```

```
$ filelines 1 > myfile
# WARNING: n=1 < 2. limited output
$ cat myfile
1
```

## `waitforjobs`
`waitforjobs` tracks the number of forked child processes. It waits `SLEEPTIME` and polls the count until there are fewer than `MAXJOBS` jobs running. It uses shell job control facilities and is useful for local, single user, or small servers. On HPC, you'd use `sbatch` from e.g. `slurm` or `torque`. Other alternatives include [`bq`](https://github.com/sitaramc/bq) and [`task-spooler`](https://github.com/justanhduc/task-spooler). [GNU Parallel](https://blog.ronin.cloud/gnu-parallel/) and Make also have job dispatching facilities.

```shell title="waitforjobs"
for i in {1..20}; do
  sleep 5 & # (1)!
  waitforjobs
done
wait  # (2)!
```

1. `sleep` here is a stand in for a more useful long running command to be parallelized
2. waitforjobs will exit the final loop with MAXJOBS-1 still running. this `wait` will wait for those (but wont have the the notifications every SLEEPTIME. could consider `waitforjobs -p 1` instead.

when running locally, output looks like:
```
2023-05-24T15:38: sleep 60s on 3: sleep 5;sleep 5;bash /home/foranw/src/work/lncdtools/waitforjobs;
```

### Arguments
```
USAGE:
  waitforjobs [-j numjobs] [-s sleeptimesecs] [-c "auto"]  [-h|--help]"
```

`-c auto` is worth exploring in more detail. Using this option, a temporary file like `/tmp/host-user-basename.jobcfg` is created. Modifying the sleep and job settings in that file will affect the waitforjobs process watching it. You can change the number of cores to use in real time!


## `iffmain`
In scripts use like `eval "$(iffmain main_function)"` where `main_function` is a function defined in the script.

Defensive shell scripting calls for `set -euo pipefail` but running that (e.g. via `source`) on the command line will break other scripts and normal interactive shell [^sete_break]. `iffmain` is modeled after the python idiom `if __name__ == "__main__"`. When the script is not sourced, it toggles the ideal settings and sets a standard `trap` to notify on error.

### Sourcing
Using `iffmain` makes it easier to write bash scripts that are primarily functions. Scripts styled this way are easy to source and test.

A bash file that can be sourced can be reused and is able to be tested. See
[Bash Test Driven Development](https://neuro-programmers.pitt.edu/wiki/doku.php?id=public:bash_tdd)

### Template
```shell title="iffmain template"
if [[ "$(caller)" == "0 "* ]]; then
  set -euo pipefail
  trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error $e"' EXIT
  MAINFUNCNAME "$@"
  exit $?
fi
```

[^sete_break]: `set -e` "exit on an error" is especially disruptive.  One typo command and your interactive shell closes itself. 

## Example Script

As an example, we'll use `drytee`, `dryrun`, and `waitforjobs` in the script `tat2all.bash` to

  * run [`tat2`](tat2) (`tat2_single`) on a collection of bold files
  * in parallel (`all_parallel`) and 
  * need to do a few checks (`input_checks`) before hand.

We'll support 

  * printing what the script would do instead of actually doing it (`dryrun` and `drytee`) and
  * using hygienic shell settings (e.g. `set -euo pipefail`) only when run as a file but not when sourced [^sourcetest]

```shell title="tat2_all.bash" linenums="1"
#!/usr/bin/env bash

# create a 1D 0/1 binary censor file based on FD > 0.3mm
create_censor(){
   mot=${1//bold.nii.gz/motion.txt} # sub*rest_motion.txt
   out=${1//bold.nii.gz/fdcen.1D}   # sub*rest_fdcen.1D
   [ ! -r "$mot" ] && warn "no $mot!" && return 1 # (5)!
   fd_calc 1:3 4:6 deg .3 < "${mot}" |
     drytee "$out" # (1)!

   # pass output censor file name so it can be captured
   echo "$out"
}

# run tat2 for a given bold epi
# remove high motion timepoints from calculation
tat2_single(){
   local input
   input="${1:?input.nii.gz needed}"
   out=$(create_censor "$input")
   dryrun tat2 "$input" -censor "$out" # (2)!
}

# run tat2 for all bold image files in parallel
tat2_parallel(){
  FILES=(sub-*/ses-*/func/*bold.nii.gz)

  for input in "${FILES[@]}"; do
     tat2_single "$input" &
     waitforjobs # (3)!
     # for testing, just run one using:
     # break
  done

  # hold until the final set of jobs to finish
  wait
}

eval "$(iffmain tat2_parallel)" # (4)!
```

1. `drytee` writes to the specified file unless `DRYRUN` is set, then it truncates the output and writes output to stderr.
2. `dryrun` echos everything after it to `stderr` if `DRYRUN` is set. Otherwise, it runs the command.
3. `waitforjobs` watches the children of the current process and sleeps until there are fewer than 10 running.
4. `iffmain` generates bash code. It runs `set -euo pipefail` and the specified function only if file is not sourced -- e.g. `bash tat2_all.bash` or `./tat2_all.bash` [^sourcetest]
5. `warn` sends a message to `stderr` so it doesn't get included in any eval/capture -- `a=$(warn 'oh no'; echo 'yes')` yields `a="yes"`


### In Use
If we have files like
```
sub-1
└── ses-1
    └── func
        ├── sub-1_ses-1_func_task-rest_bold.nii.gz
        └── sub-1_ses-1_func_task-rest_motion.txt
```

If we set `DRYRUN`, we'll see what the script would do: a "dry run".
```shell
DRYRUN=1 ./tat2_all.bash
```

```bash
#       1
#       1
#       1
#       0
#       1 # (1)
# would be written to sub-1/ses-1/func/sub-1_ses-1_func_task-rest_fdcen.1D  # (2)
tat2 sub-1/ses-1/func/sub-1_ses-1_func_task-rest_bold.nii.gz -censor sub-1/ses-1/func/sub-1_ses-1_func_task-rest_fdcen.1D
# (3)!
```

1. output of `fd_calc`, `drytee` truncated, prefixed with `#\t` and sent to stderr
2. `drytee` also mentions what file it would have created. This file still does not exist
3. `dryrun` shows but does not run the `tat2` command.

### Source/Debug
Because the bash file is only functions and `iffmain` does not run if sourced, we can debug with `source`.
Here we'll run the `create_censor` function defined in `tat2_all.bash` to check that it does what we expect.

```bash
source tat2_all.bash
create_censor sub-1/ses-1/func/sub-1_ses-1_func_task-rest_bold.nii.gz
cat sub-1/ses-1/func/sub-1_ses-1_func_task-rest_fdcen.1D
```

```text title="sub-1/ses-1/func/sub-1_ses-1_func_task-rest_fdcen.1D"
1
1
1
0
1
1
```



[^sourcetest]: sourcing a shell script is useful for running same-file tests with bats and/or embedding the current file in other scripts to reuse function definitions. See [Sourcing][#sourcing]
