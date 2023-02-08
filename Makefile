.PHONY: docker test coverage docker-test
all: warn dryrun.exe

warn: src/warn.c
	gcc -o $@ $<

# 20221203. not ready to replace shell code with c code (chatgpt)
dryrun.exe: src/dryrun.c
	gcc -o $@ $<

test: warn
	bats --tap t/
	perl-run-end dcmtab_bids

docker:
	docker build -t lncd/tools . 

docker-test:
	docker run lncd/tools make test

coverage:
	kcov --bash-dont-parse-binary-dir --exclude-path=/usr,/tmp t/coverage/ bats t/
