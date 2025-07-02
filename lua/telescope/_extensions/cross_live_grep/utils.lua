-- from
-- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/master/lua/telescope/_extensions/file_browser/utils.lua

local _utils = {
}

_utils.get_require = function(namespace, req)
  if namespace[req] == nil then
    namespace[req] = require(req)
  end
  return namespace[req]
end

_utils.merge_default = function(default_conf, conf)
  for k, v in pairs(default_conf) do
    if conf[k] == nil then
      conf[k] = v
    end
  end
  return conf
end

_utils.update_cwd_path = function(conf)
  local cwd = vim.loop.cwd()
  conf.cwd = conf.cwd and _utils.to_absolute_path_dir(conf.cwd) or cwd
  conf.path = conf.path and _utils.to_absolute_path_dir(conf.path) or conf.cwd
  return conf
end

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
  local plenary_path = _utils.get_require(_utils, 'plenary.path')

  return plenary_path:new(src):make_relative(cwd)
end

-- @param src (string): path to file
-- @param pattern (string): pattern to search
-- @param is_pattern (bool): is it a plain string or lua pattern
-- @param callback(src, lnum, start, end): callback when found
_utils.grep_file = function(src, pattern, is_pattern, callback)
  local plenary_path = _utils.get_require(_utils, 'plenary.path')

  local i = 0
  for v in plenary_path:new(src):iter() do
    i = i + 1
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
  local plenary_scan = _utils.get_require(_utils, 'plenary.scandir')

  local end_now = false

  local search_pattern = function(entry)
    if end_now then
      return false
    end
    for _, exclude_patt in ipairs(opts.exclude) do
      local found = string.find(entry, exclude_patt)
      if found ~= nil then
        return false
      end
    end
    return true
  end

  local on_insert = function(entry)
    if not end_now then
      opts.on_insert(entry)
    end
  end

  local on_exit = function(_)
    if not end_now then
      opts.on_exit()
    end
  end

  plenary_scan.scan_dir_async(opts.path, {
    hidden = opts.hidden,
    respect_gitignore = opts.respect_gitignore,
    on_insert = on_insert,
    search_pattern = search_pattern,
    on_exit = on_exit,
  })

  local close = function()
    end_now = true
  end

  return close
end

return _utils
