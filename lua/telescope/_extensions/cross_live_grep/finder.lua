local _finders = {
  has_finder = false,
  has_utils = false,
}

-- @param opts: options
--   opts.cwd (string):    current workind directory
--   opts.path (string):   path to search
--   opts.exclude (list(str)):   pattern to exclude from results
--   opts.respect_gitignore (bool): if true, don't look in gitignored files
--   opts.hidden (bool): if true, look in hidden files (starting with '.' in their filename)
_finders.cross_live_grep = function(opts)
  if not _finders.has_utils then
    _finders.utils = require('telescope._extensions.cross_live_grep.utils')
    _finders.has_utils = true
  end

  local callable = function(_, prompt, process_result, process_complete)
    if prompt == '' then
      process_complete()
      return
    end

    local is_pattern_found = string.find(prompt, '/r/', 1, true)
    local is_pattern = false
    if is_pattern_found ~= nil and is_pattern_found[1] == 1 then
      prompt = string.sub(prompt, is_pattern_found[2])
      is_pattern = true
    end

    local display = function(entry)
      return _finders.utils.to_relative(entry.path, opts.cwd) .. ':' .. entry.lnum
    end

    local on_insert = function(entry)
      local callback_found = function(src, lnum, start, finish)
        vim.schedule(function()
          process_result({
            display = display,
            path = src,
            lnum = lnum,
            ordinal = src,
            start = start,
            finish = finish,
          })
        end)
      end
      _finders.utils.grep_file(entry, prompt, is_pattern, callback_found)
    end

    local on_exit = function()
      process_complete()
    end

    _finders.utils.scan_dir_async({
      path = opts.path,
      hidden = opts.hidden,
      respect_gitignore = opts.respect_gitignore,
      exclude = opts.exclude,
      on_insert = on_insert,
      on_exit = on_exit,
    })
  end

  return setmetatable({
    close = function()
    end,
  }, {
    __call = callable
  })
end

return _finders.cross_live_grep
