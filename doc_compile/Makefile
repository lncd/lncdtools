.PHONY: all clear
all: _build/html/index.html
clean:
	rm -r src/ doxygen/ _build/

src/.created: $(shell find .. -maxdepth 1 -type f)
	./add_extensions.sh
	date > $@

doxygen/xml/index.xml: Doxyfile src/.created | doxygen-bash.sed .doxygen-filter-perl.found
	doxygen

_build/html/index.html: conf.py $(wildcard *.rst) doxygen/xml/index.xml readme.rst | .venv/bin/sphinx-build
	PYTHONPATH=./ uv run sphinx-build -M html "." "_build"

readme.rst: ../README.md
	pandoc $< -o $@

## depends

.venv/bin/sphinx-build:
	uv venv
	uv install -r requirements.txt

doxygen-bash.sed:
	curl https://raw.githubusercontent.com/Anvil/bash-doxygen/refs/heads/master/doxygen-bash.sed > $@
	chmod +x $@

.doxygen-filter-perl.found:
	yes|cpan -a Doxygen::Filter::Perl File::Slurp Perl::RunEND
	which doxygen-filter-perl
	which doxygen-filter-perl > $@
