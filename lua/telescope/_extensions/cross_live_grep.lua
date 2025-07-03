local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)')
end

local clg_picker = require('telescope._extensions.cross_live_grep.picker')
local clg_utils = require('telescope._extensions.cross_live_grep.utils')

local _ext = {}

_ext.cross_live_grep = function(opts)
  opts = opts or {}
  opts = clg_utils.merge_default(_ext.opts, opts)

  clg_picker(opts)
end

return telescope.register_extension({
  setup = function(opts)
    _ext.opts = opts
  end,
  exports = {
    cross_live_grep = _ext.cross_live_grep,
    _picker = clg_picker
  },
})
