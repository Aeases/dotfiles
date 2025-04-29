-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    'saifulapm/neotree-file-nesting-config',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  config = function(_, opts)
    opts.nesting_rules = require('neotree-file-nesting-config').nesting_rules
    require('neo-tree').setup(opts)
  end,

  opts = {
    close_if_last_window = true,
    sort_case_insensitive = false, -- used when sorting files and directories in the tree
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function()
          vim.cmd [[
            setlocal relativenumber
          ]]
        end,
      },
    },
    default_component_configs = {
      container = {
        enable_character_fade = true,
      },
      indent = {
        with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = '',
        expander_expanded = '',
        expander_highlight = 'NeoTreeExpander',
      },

      git_status = {
        symbols = {
          unstaged = '未追加',
          staged = '既追加',
          untracked = '未登録',
        },
      },
      modified = {
        symbol = '未保存',
        highlight = 'NeoTreeModified',
      },
    },
    filesystem = {
      filtered_items = {
        always_show = {
          '.gitignore',
          '.zprofile',
          '.zshrc',
          '.profile-linux',
        },
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
