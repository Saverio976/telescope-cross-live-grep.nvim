local get_values = function()
  local values = {
    cwd = nil,
    path = nil,
    respect_gitignore = true,
    hidden = true,
    exclude = {'%.git/', '__pycache__/', 'node_modules/', 'dist/', '%.gradle/', '%.idea/', '%.vscode/', '%.dll', '%.d'},
    use_fastest = true,
  }
  return values
end

return get_values
