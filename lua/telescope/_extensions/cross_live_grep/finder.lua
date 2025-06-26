local _finders = {
  has_scan = false,
  has_async = false,
}

_finders.cross_live_grep = function(opts)
  if not _finders.has_scan then
    _finders.scan = require('plenary.scandir')
    _finders.has_scan = true
  end
  if not _finders.has_async then
    _finders.async = require('plenary.async')
    _finders.has_async = true
  end

  opts = opts or {}

  local job
  local results = {}
  local job_started = false

  return setmetatable({
    results = results,
    entry_maker = entry_maker,
  }, {
    __call = function(_, _, process_result, process_complete)
      if not job_started then
        scan.scan_dir_async(opts.path, {
          hidden = true,
          respect_gitignore = true,
          search_pattern = function(e)
            return true
          end,
          on_insert = function(e)
            process_result(e) -- TODO:
          end,
          on_exit = function(results)
            process_complete()
          end,
        })
        job_started = true
      end
    end
  })
end

return _finders.cross_live_grep
