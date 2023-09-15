---
title: About
---

# Overview
[![DOI](https://zenodo.org/badge/152143120.svg)](https://zenodo.org/badge/latestdoi/152143120)

[lncdtools](//github.com/lncd/lncdtools) is a suit of shell scripting, GNU Make, and general neuroimaging [^AFNI] companion tools developed in the [Laboratory of NeuroCognitive Development](https://lncd.pitt.edu).

Also see [LNCDR](https://github.com/LabNeuroCogDevel/LNCDR) for GNU R functions. 

[^AFNI]: mostly via [AFNI](afni.nimh.nih.gov/)
## Highlights

* [setup](lncdtools_setup) - guide for "installing": clone and add to path
* [`tat2`](tat2) - documentation for calculate time average T2* on 4D EPI
* [BIDS](BIDS) - converting DICOM folders to a BIDS spec file hierarchy using `dcmdirtab`, `dcmtab_bids`, and `mknii`
* [shell scripting tools](shell) - docs for shell scripting with `iffmain`,  `waitforjobs`, `dryrun`, `drytee`
* `niinote` - warp a nifti creating command to append AFNI's note header (ad hoc provenance)
* `mkls`, `mkifdiff`, `mkstat`, `mkmissing` - tools for using make with sentinel files
* `3dDeconLogGLTs` `3dmaskave_grp` `3dMinStdClust` `3dNotes_each` `3dSeedCorr` `4dConcatDataTable` `4dConcatSubBriks` - afni extensions
