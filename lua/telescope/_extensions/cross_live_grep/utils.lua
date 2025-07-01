-- from
-- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/master/lua/telescope/_extensions/file_browser/utils.lua

local _utils = {
  has_path = false,
  has_scan = false,
}

_utils.to_absolute_path_dir = function(str)
  if not _utils.has_path then
    _utils.path = require('plenary.path')
    _utils.has_path = true
  end

  str = vim.fn.expand(str)
  local path = _utils.path:new(str)
  if not path:exists() then
    return nil
  elseif not path:is_dir() then
    return nil
  end
  return path:absolute()
end

_utils.to_relative = function(src, cwd)
  if not _utils.has_path then
    _utils.path = require('plenary.path')
    _utils.has_path = true
  end

  return _utils.path:new(src):make_relative(cwd)
end

_utils.grep_file = function(src, pattern)
  if not _utils.has_path then
    _utils.path = require('plenary.path')
    _utils.has_path = true
  end

  local lines_tmp = _utils.path:new(src):readlines()
  local lines = {}
  for i, v in ipairs(lines_tmp) do
    table.insert(lines, {
      str = v,
      i = i
    })
  end
  local found = vim.fn.matchfuzzypos(lines, pattern, {
    key = 'str',
    matchseq = true,
    limit = 0,
  })
  local results = {}
  for i = 1, #(found[1]) do
    table.insert(results, {
      -- path, line_number, column_number
      src, found[1][i].i, found[2][i][1], found[2][i][2]
    })
  end

  return results
end

-- @param opts: options
--   opts.path (string):   path
--   opts.hidden (bool):   if true, check for hidden files too
--   opts.respect_gitignore (bool):   if true, only files not ignored by git
--   opts.exclude (list(str)):    exclude this patterns
--   opts.on_insert(entry):  called when a file matches
--   opts.on_exit():  called at the end
_utils.scan_dir = function(opts)
  if not _utils.has_scan then
    _utils.scan = require('plenary.scandir')
    _utils.has_scan = true
  end

  local search_pattern = function(entry)
    local _match = vim.schedule_wrap(vim.fn.match)
    for _, exclude_patt in ipairs(opts.exclude) do
      if _match(entry, exclude_patt) ~= -1 then
        return false
      end
    end
    return true
  end

  local on_insert = function(entry)
    opts.on_insert(entry)
  end

  local on_exit = function(_)
    opts.on_exit()
  end

  _utils.scan.scan_dir_async(opts.path, {
    hidden = opts.hidden,
    respect_gitignore = opts.respect_gitignore,
    on_insert = on_insert,
    search_pattern = search_pattern,
    on_exit = on_exit,
  })
end

return _utils
