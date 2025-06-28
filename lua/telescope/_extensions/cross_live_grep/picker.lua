local _pickers = {
  has_picker = false,
  has_utils = false,
  has_conf = false,
  has_finder = false,
}

_pickers.cross_live_grep = function(opts)
  if not _pickers.has_picker then
    _pickers.picker = require('telescope.pickers')
    _pickers.has_picker = true
  end
  if not _pickers.has_utils then
    _pickers.utils = require('telescope._extensions.cross_live_grep.utils')
    _pickers.has_utils = true
  end
  if not _pickers.has_conf then
    _pickers.conf = require('telescope.config').values
    _pickers.has_conf = true
  end
  if not _pickers.has_finder then
    _pickers.finder = require('telescope._extensions.cross_live_grep.finder')
    _pickers.has_finder = true
  end

  local cwd = vim.loop.cwd()
  opts = opts or {}
  opts.cwd = opts.cwd and _pickers.to_absolute_path_dir(opts.cwd) or cwd
  opts.path = opts.path and _pickers.to_absolute_path_dir(opts.path) or opts.cwd

  local clg_finder = _pickers.finder(opts)

  _pickers.picker.new(opts, {
    prompt_title = "Cross Live Grep",
    finder = clg_finder,
    results_title = _pickers.utils.to_relative(opts.path, opts.cwd),
    previewer = _pickers.conf.grep_previewer(opts),
    sorter = _pickers.conf.file_sorter(opts),
    attach_mappings = function(_, _)
      return true
    end,
  }):find()
end

return _pickers.cross_live_grep
