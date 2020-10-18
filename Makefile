.PHONY: docker test

test:
	bats --tap t/
	perl-run-end dcmtab_bids

docker:
	docker build -t lncd/tools . 

docker-test:
	docker run lncd/tools make test
