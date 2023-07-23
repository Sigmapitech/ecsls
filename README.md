# Epitech Coding Style LSP 

## Dependencies

All these dependencies are needed to run the app.

### banana-vera

You need to clone the repo of the coding style of EPITECH. If you do not have
access to this repo, we are sorry but you will not be able to use this LSP, as
it is required for this to run, and it's an internal repo.
```bash
git submodules update --init --recursive
```

### Compile

```bash
pip install .
```


## Neovim

To activate the LSP using lspconfig, use this in your config
```lua
local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')

-- ↓ Epitech C Style Checker
if not configs.ecsls then
  configs.ecsls = {
    default_config = {
      root_dir = lspconfig.util.root_pattern('.git', 'Makefile'),
      cmd = { 'ecsls_run' },
      filetypes = { 'c' },
      init_options = {
        command = { 'ecsls_run' },
      },
    },
  }
end
lspconfig.ecsls.setup({})
```

