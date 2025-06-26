-- from
-- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/master/lua/telescope/_extensions/file_browser/utils.lua

local _utils = {}

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

  return _utils.path:new(src):make_relative(cwd) .. _utils.path.path.sep
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
  for i = 1, #found[1] do
    table.insert({
      -- path, line_number, column_number
      src, found[1][i].i, found[2][i][1]
    })
  end

  return results
end

return _utils
