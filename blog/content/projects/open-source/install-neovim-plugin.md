---
title: "Install Eunuch Neovim Plugin"
date: 2023-08-09T07:10:45-06:00
draft: false
---

For macOS:
```bash
# Plugins in the 'start' directory are autoloaded when neovim starts
mkdir -p ~/.config/nvim/pack/plugins/start

git clone https://github.com/tpope/vim-eunuch.git ~/.config/nvim/pack/plugins/start/eunuch
chmod -R 755 ~/.config/nvim/pack/plugins/start/eunuch
```

On linux, open neovim and check your package path with `:set packpath?`. Replace ~/.config/nvm with whatever's the package path in your home directory.
