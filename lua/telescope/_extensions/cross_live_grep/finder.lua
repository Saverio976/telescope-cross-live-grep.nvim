local _finders = {
  has_scan = false,
  has_finder = false,
  has_utils = false,
}

-- @param opts: options
--   opts.cwd (string):    current workind directory
--   opts.path (string):   path to search
_finders.clg = function(opts)
  if not _finders.has_scan then
    _finders.scan = require('plenary.scandir')
    _finders.has_scan = true
  end

  local cwd = vim.loop.cwd()

  local callable = function(_, prompt, process_result, process_complete)
    if prompt == '' then
      process_complete()
    end


    local display = function(entry)
      return entry.path .. ':' .. entry.lnum
    end

    local index = 0

    local on_insert = function(entry)
      index = index + 1
      process_result({
        display = display,
        path = entry,
        lnum = 1,
        index = index
      })
      -- local local_result = _finders.utils.grep_file(cur_path, opts.pattern)
      -- for _, cur_match in ipairs(local_result) do
      --   table.extend(results, cur_match)
      --   vim.notify(cur_match[1])
      -- end
    end
    local data = _finders.scan.scan_dir(opts.path, {
      hidden = true,
      respect_gitignore = true,
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


_finders.cross_live_grep = function(opts)
  if not _finders.has_scan then
    _finders.scan = require('plenary.scandir')
    _finders.has_scan = true
  end
  if not _finders.has_finder then
    _finders.finder = require('telescope.finders')
    _finders.has_finder = true
  end
  if not _finders.has_utils then
    _finders.utils = require('telescope._extensions.cross_live_grep.utils')
    _finders.has_utils = true
  end

  opts = opts or {}
  opts.pattern = opts.pattern or ''

  local results = {}
  if opts.pattern ~= '' then
    local results_tmp = _finders.scan.scan_dir(opts.path, {
      hidden = true,
      respect_gitignore = true,
    })

    for _, cur_path in ipairs(results_tmp) do
      local local_result = _finders.utils.grep_file(cur_path, opts.pattern)
      for _, cur_match in ipairs(local_result) do
        table.extend(results, cur_match)
        vim.notify(cur_match[1])
      end
    end
  end

  return _finders.finder.new_table({
    results = results,
    entry_maker = function(entry)
      return {
        value = entry,
        display = function(tbl)
          return _finders.to_relative(tbl.path, opts.cwd) .. ':' .. tbl.line_number .. ':' .. tbl.column_number
        end,
        path = entry[1],
        lnum = entry[2],
        column_number = entry[3],
      }
    end,
  })
end

return _finders.clg
