local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)')
end

local picker = require('telescope._extensions.cross_live_grep.picker')

local cross_live_grep = function(opts)
  opts = opts or {}

  picker(opts)
end

return telescope.register_extension({
  setup = function(opts)
  end,
  exports = {
    cross_live_grep = cross_live_grep,
    _picker = picker
  },
})
