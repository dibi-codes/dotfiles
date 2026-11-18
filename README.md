# Dotfiles

This dotfiles repo is managed by [chezmoi](https://www.chezmoi.io/).

## Setup new computer

To setup a new computer just hit:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply dibi-codes
```

`chezmoi init` asks for name, email and git signing key (SSH public key or GPG key ID).

Optional machine-local values (kept out of this public repo) go into `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
  goprivate = "dev.azure.com,github.com/example-org"
  [data.gitInsteadOf]
    "git@ssh.example.com:org/repo" = "https://example.com/org/repo"
```
