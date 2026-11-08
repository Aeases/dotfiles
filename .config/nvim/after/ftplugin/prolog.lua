package.loaded['ll.prolog'] = package.loaded['ll.prolog']
  or (function()
    local sessions = {} -- .pl path -> { buf, job }

    return function()
      local file = vim.fn.expand '%:p'
      local s = sessions[file]
      local win = s and vim.fn.bufwinid(s.buf) or -1
      if win ~= -1 then
        return vim.api.nvim_win_hide(win)
      end

      local fresh = not (s and vim.fn.jobwait({ s.job }, 0)[1] == -1)
      if fresh then
        vim.cmd.write()
        s = { buf = vim.api.nvim_create_buf(false, true) }
        sessions[file] = s
      end
      local w, h = math.floor(vim.o.columns * 0.7), math.floor(vim.o.lines * 0.7)
      vim.api.nvim_open_win(s.buf, true, {
        relative = 'editor',
        width = w,
        height = h,
        col = math.floor((vim.o.columns - w) / 2),
        row = math.floor((vim.o.lines - h) / 2) - 1,
        style = 'minimal',
        border = 'rounded',
        title = ' gprolog: ' .. vim.fn.fnamemodify(file, ':t') .. ' ',
        title_pos = 'center',
      })

      if fresh then -- jobstart(term) runs in the current buffer, so after the float is open
        s.job = vim.fn.jobstart({ 'gprolog', '--consult-file', file }, {
          term = true,
          cwd = vim.fn.fnamemodify(file, ':h'),
          on_exit = function()
            vim.schedule(function()
              if sessions[file] == s then
                sessions[file] = nil
              end
              if vim.api.nvim_buf_is_valid(s.buf) then
                vim.api.nvim_buf_delete(s.buf, { force = true }) -- also closes the float
              end
            end)
          end,
        })
        for _, lhs in ipairs { 'q', '<leader>ll' } do -- in terminal normal mode (<Esc><Esc>)
          vim.keymap.set('n', lhs, '<cmd>hide<cr>', { buffer = s.buf, desc = 'Hide gprolog float' })
        end
      end
      vim.cmd.startinsert()
    end
  end)()

vim.keymap.set('n', '<leader>ll', package.loaded['ll.prolog'], { buffer = true, desc = 'Toggle floating gprolog session on this file' })
