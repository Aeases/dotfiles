-- Highlight todo, notes, etc in comments
return {
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = true,
      keywords = {
        DIV = { icon = '分', color = '#FF0000' },
        EXPLANATION = { icon = '※', color = '#3AA99F', alt = { 'E', '？', 'PURPOSE' } },
        WUT = { icon = '?', color = '#A02F6F' },
        FUNCTION = { icon = '󰊕', color = '#CE5D97' },
        CRITICALSECTION = { icon = '󰲉', color = '#CE5D97', alt = { 'CRITICAL SECTION' } },
      },
      gui_style = {
        fg = 'BOLD', -- The gui style to use for the fg highlight group.
        bg = 'NONE', -- The gui style to use for the bg highlight group.
      },
      highlight = {
        multiline = true,
        before = 'fg', -- "fg" or "bg" or empty
        keyword = 'fg', -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        after = 'fg', -- "fg" or "bg" or empty
        pattern = [[^\s*[#,-,\/,\*]*\s<(KEYWORDS)\s*]],
      },
      search = {
        command = 'rg',
        args = {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
        },
        pattern = [[^\s*[#,-,\,/]*\s\w(KEYWORDS)\w]], -- ripgrep regex
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
