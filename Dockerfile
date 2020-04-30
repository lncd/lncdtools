from afni/afni
run apt-get update \
    && apt-get -qy install \
      bats octave dc r-cran-tidyverse \
    && rm -rf /var/lib/apt/lists/*
workdir /opt/lncd
ENV PATH="/opt/lncd:${PATH}"
add . /opt/lncd
