local _finders = {
  has_finder = false,
  has_utils = false,
}

-- @param opts: options
--   opts.cwd (string):    current workind directory
--   opts.path (string):   path to search
_finders.cross_live_grep = function(opts)
  if not _finders.has_utils then
    _finders.utils = require('telescope._extensions.cross_live_grep.utils')
    _finders.has_utils = true
  end

  local callable = function(_, prompt, process_result, process_complete)
    if prompt == '' then
      process_complete()
    end

    local display = function(entry)
      return _finders.utils.to_relative(entry.path, opts.cwd) .. ':' .. entry.lnum
    end

    local on_insert = function(entry)
      local local_result = _finders.utils.grep_file(entry, prompt)
      for _, cur_match in ipairs(local_result) do
        process_result({
          display = display,
          path = entry,
          lnum = cur_match[2],
          ordinal = entry,
          start = cur_match[3],
          finish = cur_match[4],
        })
      end
    end

    _finders.utils.scan_dir({
      path = opts.path,
      hidden = true,
      respect_gitignore = true,
      exclude = {[[\.git/*]]},
      on_insert = on_insert,
    })

    process_complete()
  end

  return setmetatable({
    close = function()
    end,
  }, {
    __call = callable
  })
end

return _finders.cross_live_grep
