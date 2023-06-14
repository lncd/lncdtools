.PHONY: docker check experiments coverage docker-test install depends
check: .make/check
docker-test:  .make/docker-test
docker: .make/docker
coverage: .make/coverage
depends: .make/depends
TESTFILES := $(wildcard t/*)

# 20230225: use perl version
# 'warn' c version does not handle \t properly
# 20221203: 'dryrun' not ready to replace shell code with c code (from chatgpt)
experiments: warn.fast dryrun.exe
warn.fast: src/warn.c
	gcc -o $@ $<
dryrun.exe: src/dryrun.c
	gcc -o $@ $<

# requires Perl::RunEND from CPAN
.make/check: $(TESTFILES) | .make/
	bats --tap t/ | tee $@
	command -v perl-run-end && perl-run-end dcmtab_bids |tee -a $@ || :

.make/docker: Dockerfile | .make/
	docker build -t lncd/tools . 
	date > $@ 

.make/docker-test: .make/docker
	docker run lncd/tools make check  > $@

.make/coverage: $(TESTFILES)
	kcov --bash-dont-parse-binary-dir --exclude-path=/usr,/tmp t/coverage/ bats t/ | tee $@

.make/depends: t/requires.txt t/cpanfile
	Rscript -e "install.packages(c('stringr','dplyr','tidyr'));"
	pip install t/requires.txt
	cpanm --installdeps t/
	date > $@

.make/:
	mkdir -p $@

## make install
# move all exec files in top level to install directory (/usr/bin)
# exclude those not useful outside of lncd server rhea
IGNORE_EXECS=V D r mrid pet_scan_age.R get_ld8_age.R fixto1809c rhea_user dryrun.exe warn.fast
EXECS := $(filter-out $(IGNORE_EXECS),$(shell find -maxdepth 1 -type f -perm /u+x -printf "%P\n"))
BIN := $(addprefix $(DESTDIR)/usr/bin/,$(EXECS))
$(DESTDIR)/usr/bin/%: %
	install -D -m 755 $< $@
install: $(BIN)
