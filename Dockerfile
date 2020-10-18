from neurodebian:nd-non-free
# 20201017 - use neurodebian sid. pull in afni
#          - afni/afni_dev_base. consider use poldracklab/fmriprep. but based on ubuntu:xenial-20200114
# 20200909 - afni uses neurodebian:nd18.04 as base
# https://github.com/afni/afni/blob/master/.docker/afni_dev_base.dockerfile
# https://github.com/neurodebian/neurodebian/ -> bionic
run apt-get update \
    && apt-get -qy install \
      afni python-pydicom bats octave dc r-cran-tidyverse \
    && rm -rf /var/lib/apt/lists/*
workdir /opt/lncd
ENV PATH="/opt/lncd:${PATH}"
add . /opt/lncd
