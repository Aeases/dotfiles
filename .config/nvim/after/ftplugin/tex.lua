package.loaded['ll.tex'] = package.loaded['ll.tex']
  or (function()
    local jobs = {} -- .tex path -> vim.system handle

    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        for _, job in pairs(jobs) do
          job:kill 'sigterm'
        end
      end,
    })

    local function open_pdf(pdf)
      vim.system({ 'pgrep', '-af', 'zathura' }, { text = true }, function(r)
        if not (r.stdout or ''):find(pdf, 1, true) then
          vim.system({ 'zathura', pdf }, { detach = true })
        end
      end)
    end

    return function()
      local file, name = vim.fn.expand '%:p', vim.fn.expand '%:t'
      if jobs[file] then
        jobs[file]:kill 'sigterm'
        jobs[file] = nil
        return vim.notify('Stopped continuous compile of ' .. name)
      end
      vim.cmd.write()

      local failed, opened, partial = false, false, ''
      local function on_output(_, data)
        if not data then
          return
        end
        local lines = vim.split(partial .. data, '\n')
        partial = table.remove(lines)
        for _, line in ipairs(lines) do
          if line:find('Errors, so I did not complete making targets', 1, true) then
            failed = true
          elseif line:find('=== Watching for updated files', 1, true) then
            if failed then
              vim.notify('LaTeX errors in ' .. name .. ' (see .build/*.log)', vim.log.levels.ERROR)
            else
              vim.notify('Compiled ' .. name)
              if not opened then
                opened = true
                open_pdf(vim.fn.fnamemodify(file, ':r') .. '.pdf')
              end
            end
            failed = false
          end
        end
      end

      vim.notify('Continuous compile of ' .. name .. ' started')
      jobs[file] = vim.system(
        { 'sh', '-c', 'exec latexmk "$@" 2>&1', 'latexmk', '-pvc', '-view=none', '-interaction=nonstopmode', file },
        { cwd = vim.fn.fnamemodify(file, ':h'), text = true, stdout = vim.schedule_wrap(on_output) },
        vim.schedule_wrap(function(r)
          if jobs[file] and r.signal == 0 then -- not an exit we caused by toggling off
            jobs[file] = nil
            vim.notify('latexmk exited (code ' .. r.code .. ')', vim.log.levels.WARN)
          end
        end)
      )
    end
  end)()

vim.keymap.set('n', '<leader>ll', package.loaded['ll.tex'], { buffer = true, desc = 'Toggle continuous LaTeX compile (latexmk -pvc) + Zathura' })
