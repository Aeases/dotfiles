-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    'saifulapm/neotree-file-nesting-config',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },

  config = function(_, opts)
    opts.nesting_rules = require('neotree-file-nesting-config').nesting_rules
    require('neo-tree').setup(opts)
  end,

  ---@module 'neo-tree'
  ---@type neotree.Config
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
          unstaged = '未準備',
          staged = '準備',
          untracked = '未追跡',
          tracked = '追跡',
          added = '追加',
          modified = '',
          deleted = '削除',
          renamed = '改名',
        },
      },
      modified = {
        symbol = '未保存',
        highlight = 'NeoTreeModified',
      },
    },
    filesystem = {
      components = {
        git_status = function(config, node, state)
          if node.type == 'message' or not node.path then
            return {}
          end

          local git = require 'neo-tree.git'
          local builtins = require 'neo-tree.sources.common.components'
          local highlights = require 'neo-tree.ui.highlights'

          local status = git.find_existing_status_code(node.path, state.git_base_by_worktree)

          if type(status) == 'table' then
            status = status[1]
          end

          -- staged modification + unstaged modification
          if status == 'MM' then
            return {
              text = '未/準備',
              highlight = highlights.GIT_MODIFIED,
            }
          end

          return builtins.git_status(config, node, state)
        end,
      },

      hijack_netrw_behavior = 'open_default',
      filtered_items = {
        always_show = {
          '.gitignore',
          '.zprofile',
          '.zshrc',
          '.profile-linux',
        },
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<space>'] = { 'toggle_node', nowait = true },
        },
      },
    },
  },
}
