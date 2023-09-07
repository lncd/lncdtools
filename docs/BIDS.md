# BIDS
The [Brain Imaging Data Struture](https://bids-specification.readthedocs.io/) standard provides a consistant organiziation for MRI data. There are [many "converters"](https://bids.neuroimaging.io/benefits.html#converters) to translate dicom scanner files into a BIDS conforming file hiearchy. This is one.

Jump to the [example](#example)

## Alternative Converters
`heudiconv` and `dcm2bids` are more popular and better supported tools.
The advantage the tools presented here have are within a narrow use-case.

 * `dcmdirtab` is faster because it does less (at the cost of robustness).
 * `dcmtab_bids` provides a small domain specific language for assigning dicom folders a modality that may be easier to grok and more ergonomic for well known modalities.
 * multiple tools allow for a more inspectible pipeline that is easier to tweak. [^1]
 * scripts contain few lines of code and can be tweaked for specific unusual input/output.

[^1]: [do one thing well](https://en.wikipedia.org/wiki/Unix_philosophy)

## Overview
The route from Dicom to BIDS can be broken into 3 

  1. extracting imaging metadata (file name, counts, dicom header)
  2. translating metadata to BIDS files names
  3. Converting images

## Example
Below converts all the dicom folders in `*/DICOM/*` to BIDS inside `bids/`

 * `dcmdb.tsv` will store the dicom metadata [^pipe]
 * `bidsname_dcmname.tsv` has the dicom folder to bids file conversion [^pipe]
 * `bids/` stores the newly created files

[^pipe]:
  alternatively, we could forgo saving files and pipe from one command directly to the next
  `dcmdirtab ... | dcmtab_bids .... | parallel ... mknii ...`

```shell title="bids to dicom in 3 steps"
dcmdirtab -s '(?<=/)[a-z]{3}' -d '*/DICOM/*' > dcmdb.tsv  # (1)!

dcmtab_bids \
 'T1w;dname=UNI-DEN,ndcm=192' \
 'bold=rest;pname=Rest,ndcm=300;2' \
 'MTR;pname=gre_NM_fa250_t14p4_df2p8khz;acq=NM' \
 < dcmdb.tsv > bidsname_dcmname.tsv

parallel --colsep '\t' mknii "bids/{1}" "{2}" < bidsname_dcmname.tsv
```

1. matching subject names like 'abc' or 'xyz' using [look behind `(?<=blah)` in a regular expressions](https://www.regular-expressions.info/lookaround.html). These are especially useful in finding names at the start of a directory but not capturing the leading `/`.

One of the many conversion this might complete:

`abc/DICOM/GRE_NM_FA250_T14P4_DF2P8KHZ_0026` => `sub-abc/anat/sub-abc_acq-NM_MTR.nii.gz`

## Tools
### metadata: `dcmdirtab`

`dcmdirtab` outputs dicom directory metadata as tab separated fields.

It matches folders from the glob provided by `-d`, extracts sub id with pattern given after `-s` and session patter after `-b`. additional columns can be added and even defined with other arguments.

This script defaults to running quickly. Unlike more robust converters, it does not inspect every dicom. Instead the first in a folder is picked as representative. This has drawbacks: multiple echos, TRs, and TEs are not tracked. This hasn't caused known problems yet.

#### Fields

The default output has the header is
```
subj    seqno   ndcm    pname   tr      matrix  acqdir  dname   fullpath
```

But there are many pre-built fields that can be extracted

```
 dcmdirtab -l
Built in columns:
        fullpath => CODE(0x555555d046e8)
        pname => 0018,1030
        dname => CODE(0x55555620ba58)
        inverttime => 0018,0082
        seriesdesc => 0008,103e
        station => 0008,1010
        tr => 0018,0080
        subj => (?^u:\d+)
        seqname => 0018,0024
        matrix => 0018,1310
        example => CODE(0x555556184670)
        acqdir => 0018,1312
        model => 0008,1090
        software => 0018,1020
        imagetime => 0008,0033
        accel => CODE(0x555555d03ef0)
        ndcm => CODE(0x5555559cf8e8)
        bandwidth => 0018,0095
        ses => (?^u:)
        flipangle => 0018,1314
        acqdir_alt => 0051,100e
        strength => 0018,0087
        echotime => 0018,0081
        seqno => 0020,0011
        patname => 0010,0010
```

using `-b 'sessionpattern'` implicitly adds the `ses` column


see `dcmdirtab --help` for much more.

### naming: `dcmtab_bids`


#### Input

STDIN input is a tsv with the first row as a header, exactly what `dcmdirtab` outputs. If `ses` is a column, output will include that in BIDS names (`sub-xxx/ses-yyy/*/sub-xxx_ses-yyy_*`)

Provided arguments to the command are sets of specifications to identify modalities in the dicom metadata and translate to BIDS compliant names.

```
mode;pattern,pattern[;runs][;acq=label][;dir=label]
```

Though patterns use `=`, they actually are using a regular expression to match strings.

`pname=Rest,ndcm=300` matches any protocol with "Rest" in the name. and if there were 3000 dicoms, it'd match that the same as if there are 300 (b/c "300" is in the string "3000").

#### Output
output is tab separated fields: (1) file name in bids (2) input dicom directory. like

```
sub-abc/anat/sub-abc_acq-NM_MTR.nii.gz    abc/DICOM/GRE_NM_FA250_T14P4_DF2P8KHZ_0026
...
sub-xxx/anat/sub-xxx_T1w.nii.gz   xxx/DICOM/MP2RAGEPTX_TR6000_1MMISO_UNI-DEN_0034
```


see `dcmtab_bids --help`

### create: `mknii`

`mknii` takes a dicom folder and an ideal output name on STDIN, exactly what `dcmtab_bids` outputs.

It recklessly makes whatever folder it's told is needed, uses `dcm2niix` to write `*.nii.gz`+`.json` pairs, and renames them to the given output name.

`3dNotes` is used to record the command within the nifti file for posterity as provenance. **NB. if you have PHI/PII in the dicom folder name, this will be pushed into header of the `.nii.gz` file** 

## lncdtools with perl and afni on HPC
`dcmdirtab` uses requires a perl >=5.26 in addition to `dicom_hinfo` form AFNI. For advance usage (evaluating perl configuration file), a library from CPAN `File::Slurp` is also used.

Unfortunately this can complicate setup.  Here's an example script to `source`, used on Pitt's CRC HPC cluster.

```bash
# use newer perl. as of 2023-09-07, newest on CRC loaded like
module load gcc/8.2.0 perl/5.28.0

# and we need afni
module load afni

export PATH="$PATH:/path/to/cloned/lncdtools"

# ---
# this is only need if using `-e config.pl` option of dcmdirtab (unlikley)
# ---
#
# File::Slurp (and implicitly local::lib) only need to be install once
# cpan is interactive, must pick lib::local (i.e. dont change the defaults)
! test -d $HOME/perl5/lib/perl5 &&
        cpan install File::Slurp

# export the environment perl needs to know where lib::local stuff lives
eval $(PERL5LIB="$HOME/perl5/lib/perl5" perl -Mlocal::lib)
```
