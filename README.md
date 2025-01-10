# [ECSLS] Epitech Coding Style Language Server

![image](https://github.com/Sigmapitech-meta/ecsls/assets/53050011/87543f76-5eb2-4a58-a685-37592aae38bf)

## Dependencies

### Nix

- Via Home Manager

Using Home Manager, you can use the github url as an input and pass it to your
nvim config.

Set `ecsls.packages.${conf.system}.default` within the `neovim.extraPackages`
option and refer to the neovim configuration after the dependencie section.

- Development packages are provided throught `nix develop`.

### Non-Nix

- Install `banana-vera` package if existing, or you compile it by
[yourself](https://gist.github.com/Sigmanificient/6ef147920ad057ef6bcd9b057f81d83d).

#### Epitech Ruleset

You need to clone the repo of the coding style of EPITECH. If you do not have
access to this repo, we are sorry but you will not be able to use this LSP, as
it is required for this to run, and is internal to Epitech.

```bash
git submodules update --init --recursive
```

> or
```bash
git clone https://github.com/Epitech/banana-coding-style-checker.git <path>
```

#### Setup ECSLS python package

> (optional) Create a virtual environement (avoid polluting your python).
```py
python -m venv venv
```

> Install the package locally.
```bash
venv/bin/pip install .
```

> **Note**
> If you are using virtual environments, don't forget to add the correct path
> for the command in your LSP config


## Setup

To activate ecsls as a language server, you'll need to create a custom LSP in
your editor.

Once it is done, you'll need to create a `ecsls.toml` to tell the LSP to run
as it is quite heavy and can be annoying.

### Neovim

To activate the language server using
[lspconfig](https://github.com/neovim/nvim-lspconfig), use the following
configuration:

```lua
local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')

-- ↓ Epitech C Style Checker
if not configs.ecsls then
  configs.ecsls = {
    default_config = {
      root_dir = lspconfig.util.root_pattern('.git', 'Makefile'),
      cmd = { 'ecsls_run' },
      autostart = true,
      name = 'ecsls',
      filetypes = { 'c', 'cpp', 'make' },
    },
  }
end
lspconfig.ecsls.setup({})
```

### Emacs

```lisp
(require 'lsp-mode)
(lsp-register-client
  (make-lsp-client :new-connection (lsp-stdio-connection '("ecsls_run"))
                   :major-modes '(c-mode c++-mode makefile-mode)
                   :server-id 'ecsls))

(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)
(add-hook 'makefile-mode-hook 'lsp)
```

### VSCode

(not using lspconfig)

> [!CAUTION]
> Do not use the script on nixos, just import it in your home config

> [!WARNING]
> You need sudo perm for the script to work

> [!WARNING]
> You need to have access to repo owned by Epitech

```sh
./install_as_vscode_extension.sh
```

### Change the ruleset path

> **Note**
> If you want to use it globally, or if you wish to change the vera rules
> directory, change `path` in by using `init_options`.

```lua
init_options = {
  path = '/your/custom/path',
},
```

> **Warning**
> The path must be valid and pointing to the epitech ruleset repository root.

```py
path = ".../ls/banana"  # invalid
path = ".../ls/banana-coding-style-checker/vera"  # invalid too
path = ".../ls/banana-coding-style-checker"  # valid
```

To see a configuration in more details, consider reading
[my dotfiles](https://github.com/Sigmanificient/dotfiles/blob/master/home/nvim/default.nix).
