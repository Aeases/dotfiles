-- Running `latexmk -pvc` jobs, keyed by .tex path. Global so every tex buffer shares it.
_G.latexmk_jobs = _G.latexmk_jobs or {}
local jobs = _G.latexmk_jobs

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('latexmk_pvc', { clear = true }),
  callback = function()
    for _, job in pairs(jobs) do
      job:kill 'sigterm'
    end
  end,
})

local function open_pdf(pdf_file)
  local pgrep_result = vim.system({ 'pgrep', '-af', 'zathura' }, { text = true }):wait()
  local already_open = pgrep_result.stdout ~= nil and pgrep_result.stdout:find(pdf_file, 1, true) ~= nil
  if not already_open then
    vim.system({ 'zathura', pdf_file }, { detach = true })
  end
end

vim.keymap.set('n', '<leader>ll', function()
  local tex_file = vim.fn.expand '%:p'
  local name = vim.fn.expand '%:t'

  if jobs[tex_file] then
    jobs[tex_file]:kill 'sigterm'
    jobs[tex_file] = nil
    vim.notify('Stopped continuous compile of ' .. name, vim.log.levels.INFO)
    return
  end

  vim.cmd 'write'

  local pdf_file = vim.fn.expand '%:p:r' .. '.pdf'
  local dir = vim.fn.expand '%:p:h'
  local failed = false
  local opened = false

  -- latexmk prints this after every build attempt, so it marks the end of one compile
  local function handle_line(line)
    if line:find('Errors, so I did not complete making targets', 1, true) then
      failed = true
    elseif line:find('=== Watching for updated files', 1, true) then
      local ok = not failed
      failed = false
      vim.schedule(function()
        if ok then
          vim.notify('Compiled ' .. name, vim.log.levels.INFO)
          if not opened then
            opened = true
            open_pdf(pdf_file)
          end
        else
          vim.notify('LaTeX errors in ' .. name .. ' (see .build/*.log)', vim.log.levels.ERROR)
        end
      end)
    end
  end

  -- latexmk output arrives in arbitrary chunks on both streams; react to whole lines only
  local function line_reader()
    local partial = ''
    return function(_, data)
      if not data then
        return
      end
      local lines = vim.split(partial .. data, '\n')
      partial = table.remove(lines)
      for _, line in ipairs(lines) do
        handle_line(line)
      end
    end
  end

  vim.notify('Continuous compile of ' .. name .. ' started', vim.log.levels.INFO)

  jobs[tex_file] = vim.system(
    { 'latexmk', '-pvc', '-view=none', '-interaction=nonstopmode', tex_file },
    { cwd = dir, text = true, stdout = line_reader(), stderr = line_reader() },
    function(result)
      vim.schedule(function()
        -- Only report exits we didn't cause by toggling off
        if jobs[tex_file] and result.signal == 0 then
          jobs[tex_file] = nil
          vim.notify('latexmk exited (code ' .. result.code .. ')', vim.log.levels.WARN)
        end
      end)
    end
  )
end, { buffer = true, desc = 'Toggle continuous LaTeX compile (latexmk -pvc) + Zathura' })
