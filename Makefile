.PHONY: docker check experiments coverage docker-test install

# 20230225: use perl version
# 'warn' c version does not handle \t properly
# 20221203: 'dryrun' not ready to replace shell code with c code (from chatgpt)
experiments: warn.fast dryrun.exe
warn.fast: src/warn.c
	gcc -o $@ $<
dryrun.exe: src/dryrun.c
	gcc -o $@ $<

# requires Perl::RunEND from CPAN
check:
	bats --tap t/
	command -v perl-run-end && perl-run-end dcmtab_bids || :

docker:
	docker build -t lncd/tools . 

docker-test:
	docker run lncd/tools make check 

coverage: #$(wildcard t/*bats)
	kcov --bash-dont-parse-binary-dir --exclude-path=/usr,/tmp t/coverage/ bats t/

## make install
# move all exec files in top level to install directory (/usr/bin)
# exclude those not useful outside of lncd server rhea
IGNORE_EXECS=V D r mrid pet_scan_age.R get_ld8_age.R fixto1809c rhea_user 
EXECS := $(filter-out $(IGNORE_EXECS),$(shell find -maxdepth 1 -type f -perm /u+x -printf "%P\n"))
BIN := $(addprefix $(DESTDIR)/usr/bin/,$(EXECS))
$(DESTDIR)/usr/bin/%: %
	install -D -m 755 $< $@
install: $(BIN)
