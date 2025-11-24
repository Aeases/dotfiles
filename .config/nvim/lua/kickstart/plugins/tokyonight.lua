return {
  {
    'nuvic/flexoki-nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    dependencies = {
      'xiyaowong/transparent.nvim',
    },
    init = function()
      vim.cmd.colorscheme 'flexoki'
      require('transparent').setup {
        transparent = vim.g.transparent_enabled,
      }
      vim.cmd.hi 'Comment gui=none'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
