_: {
  plugins.oil = {
    enable = true;
  };
  extraConfigLua = ''vim.keymap.set("n", "-", "<CMD>Oil<CR>")'';
}
