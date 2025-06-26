-- from
-- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/master/lua/telescope/_extensions/file_browser/utils.lua

local _utils = {}

_utils.to_absolute_path_dir = function(str)
  if not _utils.has_path then
    _utils.path = require('plenary.path')
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
  end

  return _utils.path:new(src):make_relative(cwd) .. _utils.path.path.sep
end

return _utils
