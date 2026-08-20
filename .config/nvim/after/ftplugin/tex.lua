vim.keymap.set('n', '<leader>ll', function()
  vim.cmd 'write'

  local tex_file = vim.fn.expand '%:p'
  local pdf_file = vim.fn.expand '%:p:r' .. '.pdf'
  local dir = vim.fn.expand '%:p:h'

  vim.notify('Compiling ' .. vim.fn.expand '%:t' .. '...', vim.log.levels.INFO)

  vim.system({ 'xelatex', '--shell-escape', '-interaction=nonstopmode', tex_file }, { cwd = dir }, function(compile_result)
    vim.schedule(function()
      if compile_result.code ~= 0 then
        vim.notify('xelatex failed (exit ' .. compile_result.code .. ')', vim.log.levels.ERROR)
        return
      end

      local pgrep_result = vim.system({ 'pgrep', '-af', 'zathura' }, { text = true }):wait()
      local already_open = pgrep_result.stdout ~= nil and pgrep_result.stdout:find(pdf_file, 1, true) ~= nil

      if not already_open then
        vim.system({ 'zathura', pdf_file }, { detach = true })
      else
        vim.notify('Zathura already has ' .. vim.fn.fnamemodify(pdf_file, ':t') .. ' open', vim.log.levels.INFO)
      end
    end)
  end)
end, { buffer = true, desc = 'Compile LaTeX with xelatex and open in Zathura' })
