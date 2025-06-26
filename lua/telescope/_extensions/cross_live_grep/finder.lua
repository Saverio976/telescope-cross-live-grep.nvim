local _finders = {
  has_scan = false,
  has_finder = false,
  has_utils = false,
}

_finders.cross_live_grep = function(opts)
  if not _finders.has_scan then
    _finders.scan = require('plenary.scandir')
    _finders.has_scan = true
  end
  if not _finders.has_finder then
    _finders.finder = require('telescope.finder')
    _finders.has_finder = true
  end
  if not _finders.has_utils then
    _finders.utils = require('telescope._extensions.cross_live_grep.utils')
    _finders.has_utils = true
  end

  opts = opts or {}
  opts.pattern = opts.pattern or ''

  local _cross_live_grep = function()
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
          line_number = entry[2],
          column_number = entry[3],
        }
      end,
    })
  end

  return _cross_live_grep
end

return _finders.cross_live_grep
