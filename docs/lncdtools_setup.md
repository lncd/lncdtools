# Setup
## Bleeding edge
The quickest way to get the most up-to-date lncdtools is to clone and add the new directory to your `$PATH`. Modify your shell login resource file to make the addition more perminate.

```bash
git clone https://github.com/lncd/lncdtools.git $HOME/lncdtools # (1)
export PATH="$PATH:$HOME/lncdtools"

echo 'export PATH="\$PATH:$HOME/lncdtools"' >> $HOME/.bashrc # (2)
```

1. `$HOME/lncdtools` can be whereever and named whatever. 
2. `$HOME/.bashrc` should be what your shell sources on login. it mighte be `~/.zshrc` on mac or `~/.bash_profile` elewhere

## Debian
`Makefile` can create .deb packages for installing on debian and ubuntu. This will hopefully be included on the [releases page](https://github.com/lncd/lncdtools/releases/) in the future

## Docker
see `Dockerfile`

## Nix

TODO (last edit: 20230815)
