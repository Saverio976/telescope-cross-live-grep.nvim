# telescope-cross-live-grep.nvim

`telescope-cross-live-grep.nvim` is a `live_grep` replacement that use only lua to discover files and grep them.

You can specify an option to use the default telescope.live_grep if the vimgrep command exists. (see configuration)

It might be less performant for a lot of files / large files, but it works consitently on linux and windows.

The '`grep`' command used is `string.find` from lua.

Documentation for pattern matching is: <https://www.lua.org/manual/5.3/manual.html#6.4.1>

Pattern matching is used only when the prompt starts with `/r/`

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

[Default configuration](./lua/telescope/_extensions/cross_live_grep/conf.lua)

```lua
-- You don't need to configure the options if the defaults are ok for you
require("telescope").setup({
    extensions = {
        cross_live_grep = {
            -- configuration options here
            use_fastest = true, -- use telescope.live_grep if vimgrep command exists. It is usually faster
        },
    },
})

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
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for file / path manipulation
