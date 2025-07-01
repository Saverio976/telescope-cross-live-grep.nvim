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

-- @param src (string): path to file
-- @param pattern (string): pattern to search
-- @param is_pattern (bool): is it a plain string or lua pattern
-- @param callback(src, lnum, start, end): callback when found
_utils.grep_file = function(src, pattern, is_pattern, callback)
  if not _utils.has_path then
    _utils.path = require('plenary.path')
    _utils.has_path = true
  end

  local data = _utils.path:new(src):readlines()
  for i, v in ipairs(data) do
    local start, finish = string.find(v, pattern, 1, is_pattern)
    if start ~= nil then
      callback(src, i, start, finish)
    end
  end
end

-- @param opts: options
--   opts.path (string):   path
--   opts.hidden (bool):   if true, check for hidden files too
--   opts.respect_gitignore (bool):   if true, only files not ignored by git
--   opts.exclude (list(str)):    exclude this patterns
--   opts.on_insert(entry):  called when a file matches
--   opts.on_exit():  called at the end
_utils.scan_dir_async = function(opts)
  if not _utils.has_scan then
    _utils.scan = require('plenary.scandir')
    _utils.has_scan = true
  end

  local search_pattern = function(entry)
    for _, exclude_patt in ipairs(opts.exclude) do
      local found = string.find(entry, exclude_patt)
      if found ~= nil then
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
