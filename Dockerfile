from afni/afni
# 20200909 - afni uses neurodebian:nd18.04 as base
# https://github.com/afni/afni/blob/master/.docker/afni_dev_base.dockerfile
# https://github.com/neurodebian/neurodebian/ -> bionic
run echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/" >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && apt-get update \
    && apt-get -qy install \
      bats octave dc r-cran-tidyverse \
    && rm -rf /var/lib/apt/lists/*
workdir /opt/lncd
ENV PATH="/opt/lncd:${PATH}"
add . /opt/lncd
