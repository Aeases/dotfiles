---@module 'lazy'
---@type LazySpec
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
      local colors = {
        Error = '#D14D41',
        Warn = '#DA702C',
        Info = '#3AA99F',
        Hint = '#D0A215',
      }
      for name, color in pairs(colors) do
        vim.api.nvim_set_hl(0, 'Diagnostic' .. name, { fg = color })
        vim.api.nvim_set_hl(0, 'DiagnosticSign' .. name, { fg = color })
        vim.api.nvim_set_hl(0, 'DiagnosticVirtualText' .. name, { fg = color })
        vim.api.nvim_set_hl(0, 'DiagnosticVirtualLines' .. name, { fg = color })
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
