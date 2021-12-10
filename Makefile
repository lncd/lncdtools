.PHONY: docker test coverage

test:
	bats --tap t/
	perl-run-end dcmtab_bids

docker:
	docker build -t lncd/tools . 

docker-test:
	docker run lncd/tools make test

coverage:
	kcov --bash-dont-parse-binary-dir --exclude-path=/usr,/tmp t/coverage/ bats t/
