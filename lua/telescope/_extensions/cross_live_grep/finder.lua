local _finders = {
}

-- @param opts: options
--   opts.cwd (string):    current workind directory
--   opts.path (string):   path to search
--   opts.exclude (list(str)):   pattern to exclude from results
--   opts.respect_gitignore (bool): if true, don't look in gitignored files
--   opts.hidden (bool): if true, look in hidden files (starting with '.' in their filename)
_finders.cross_live_grep = function(opts)
  if _finders.u == nil then
    _finders.u = require('telescope._extensions.cross_live_grep.utils')
  end

  local async_state = 0
  local async_close = nil

  local callable = function(_, prompt, process_result, process_complete)
    if prompt == '' then
      process_complete()
      return
    end

    async_state = 1

    local is_pattern_found = string.find(prompt, '/r/', 1, true)
    local is_pattern = false
    if is_pattern_found ~= nil and is_pattern_found[1] == 1 then
      prompt = string.sub(prompt, is_pattern_found[2])
      is_pattern = true
    end

    local display = function(entry)
      return _finders.u.to_relative(entry.path, opts.cwd) .. ':' .. entry.lnum
    end -- display

    local on_insert = function(entry)
      if async_state == 0 then return end
      local callback_found = function(src, lnum, start, finish)
        if async_state == 0 then return end
        vim.schedule(function()
          if async_state == 0 then return end
          process_result({
            display = display,
            path = src,
            lnum = lnum,
            ordinal = src,
            start = start,
            finish = finish,
          })
        end)
      end -- callback_found
      _finders.u.grep_file(entry, prompt, is_pattern, callback_found)
    end -- on_insert

    local on_exit = function()
      if async_state == 0 then
        return
      end
      process_complete()
    end -- on_exit

    async_close = _finders.u.scan_dir_async({
      path = opts.path,
      hidden = opts.hidden,
      respect_gitignore = opts.respect_gitignore,
      exclude = opts.exclude,
      on_insert = on_insert,
      on_exit = on_exit,
    })
  end -- callable

  return setmetatable({
    close = function()
      if async_close ~= nil then
        async_state = 0
        async_close()
        async_close = nil
      end
    end,
  }, {
    __call = callable
  })
end

return _finders.cross_live_grep
