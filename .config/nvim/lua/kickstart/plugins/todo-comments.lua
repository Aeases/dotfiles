-- Highlight todo, notes, etc in comments
return {
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
      signs = false,
      keywords = {
        DIV = { icon = "分", color = '#FF0000'}
      }
    }
  },
}
-- vim: ts=2 sts=2 sw=2 et
