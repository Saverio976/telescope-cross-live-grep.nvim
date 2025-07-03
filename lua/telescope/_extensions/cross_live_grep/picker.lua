local _pickers = {
}

-- @param opts: options
--   opts.cwd (string):               current workind directory.
--   opts.path (string):              path where to search.
--   opts.respect_gitignore (bool):   don't look in gitignored file.
--   opts.hidden (bool):              look in files starting with a dot.
--   opts.exclude (list(str)):        pattern to exclude the filename path
--   opts.use_fastest (bool):          use the fastest search finder available
_pickers.cross_live_grep = function(opts)
  if _pickers.u == nil then
    _pickers.u = require('telescope._extensions.cross_live_grep.utils')
  end
  local telescope_picker = _pickers.u.get_require(_pickers, 'telescope.pickers')
  local telescope_conf = _pickers.u.get_require(_pickers, 'telescope.config').values

  local clg_conf = _pickers.u.get_require(_pickers, 'telescope._extensions.cross_live_grep.conf')

  opts = opts or {}
  opts = _pickers.u.merge_default(clg_conf(), opts)
  opts = _pickers.u.update_cwd_path(opts)

  if opts.use_fastest and #telescope_conf.vimgrep_arguments >= 1 and vim.fn.executable(telescope_conf.vimgrep_arguments[1]) == 1 then
    local telescope_live_grep = _pickers.u.get_require(_pickers, 'telescope.builtin.__files').live_grep
    return telescope_live_grep({})
  end

  local clg_finder = _pickers.u.get_require(_pickers, 'telescope._extensions.cross_live_grep.finder')

  telescope_picker.new(opts, {
    prompt_title = "Cross Live Grep",
    finder = clg_finder(opts),
    results_title = _pickers.u.to_relative(opts.path, opts.cwd),
    previewer = telescope_conf.qflist_previewer(opts),
    attach_mappings = function(_, _)
      return true
    end,
    push_cursor_on_edit = true,
  }):find()
end

return _pickers.cross_live_grep
