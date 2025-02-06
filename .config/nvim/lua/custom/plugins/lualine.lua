return {
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = '',
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
              statusline = {},
              winbar = {},
            },
            ignore_focus = {},
            always_divide_middle = true,
            always_show_tabline = false,
            globalstatus = false,
            refresh = {
              statusline = 100,
              tabline = 100,
              winbar = 100,
            }
          },
          sections = {
            lualine_a = {'mode'},
            lualine_b = {{'datetime', style="%H:%M"}, 'branch', 'diff', 'diagnostics'},
            lualine_c = { {'filename', file_status = true, newfile_status = true, symbols = {
              modified = '●',
              readonly = '🔒',
              unnamed = '名無し',
              newfile = '新',
        } } },
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'},
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
          },
          tabline = {},
          winbar = {},
          inactive_winbar = {},
          extensions = {}
        },
  },
}
