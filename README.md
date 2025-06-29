# telescope-cross-live-grep.nvim

`telescope-cross-live-grep.nvim` is a `live_grep` replacement that use only lua to discover files and grep them.

It might be less performant for a lit of files, but it works consitently on linux and windows.

The grep vim command used is `vim.fn.matchfuzzypos`.

## Requirements

- Neovim
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Installation

```lua
--lazy
{
    "Saverio976/telescope-cross-live-grep.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
}

-- packer
use {
    "Saverio976/telescope-cross-live-grep.nvim",
    requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
}
```

## Setup and Configuration

```lua
require("telescope").load_extension('cross_live_grep')
```

## Usage

```lua
vim.keymap.set('n', 'tg',
    '<cmd>Telescope cross_live_grep<cr>',
    { desc = 'Telescope cross_live_grep', noremap = true, silent = true }
)
```

## Mappings

For now, no custom mapping is implemented. It use the default ones.

## Credits

- [nvim-telescope/telescope-file-browser.nvim](https://github.com/nvim-telescope/telescope-file-browser.nvim) inspiration for the code.
- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) inspiration from the default telescope live_grep.
