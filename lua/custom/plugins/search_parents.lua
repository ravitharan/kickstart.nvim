local function get_function_name(func_data_file, file_name, lnum)
  -- print("file_name = " .. file_name .. ", line = " .. lnum)

  local func_name = ''
  local file = io.open(func_data_file, 'r')
  if file then
    local num_files = tonumber(file:read())
    -- print("num_files " .. num_files)
    local name, file_offset, num_lines
    local found = false
    for i = 1, num_files do
      local line = file:read()
      name, file_offset, num_lines = string.match(line, '(%S+)%s+(%d+)%s+(%d+)')
      if name == file_name then
        file_offset = tonumber(file_offset)
        num_lines = tonumber(num_lines)
        found = true
        break
      end
    end
    if found then
      -- print("name = " .. name .. ", file_offset = " .. file_offset .. ", num_lines = ", num_lines)
      file:seek('set', file_offset)
      for i = 1, num_lines do
        local line = file:read()
        local line_num
        line_num, name = string.match(line, '(%d+)%s+(%S+)')
        -- print("line_num = " .. line_num .. ", func_name = " .. name)
        line_num = tonumber(line_num)
        if line_num <= lnum then
          func_name = name
        else
          break
        end
      end
    else
      print('Error, file = ' .. file_name .. ', is not in ' .. func_data_file)
    end
    file:close()
  end
  return func_name
end

local search_parents = function()
  local func_data_file = string.gsub(vim.g.FileName, 'files_', 'func_')
  func_data_file = string.gsub(func_data_file, '.txt', '')
  local abs_path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local relative_path = vim.fn.fnamemodify(abs_path, ':.')
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local func = get_function_name(func_data_file, relative_path, lnum)
  vim.fn.SearchFiles(func)
end

vim.api.nvim_create_user_command('SearchParents', search_parents, {})
