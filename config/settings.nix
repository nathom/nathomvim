{lib, pkgs, ... }:
{
  config = {
    extraFiles."lua/utils.lua".text = lib.fileContents ./lua/utils.lua;
    extraConfigLuaPre =
      # lua
      ''
      vim.cmd("command! Q qa!")
      '';

    clipboard = {
      providers.wl-copy.enable = true;
    };

    opts = {
      expandtab = true;
      smarttab = true;
      tabstop = 4;
      number = true;
      relativenumber = true;
      shiftwidth = 4;
      mouse = "a";
      autoread = true;
      encoding = "UTF-8";
      hidden = true;
      cursorline = true;
      laststatus = 3;
      errorbells = false;
      visualbell = false;
      splitbelow = true;
      splitright = true;
      tm = 500;
      lazyredraw = true;
      backup = false;
      writebackup = false;
      swapfile = false;
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;
      shell = "${lib.getExe pkgs.bash}";
      grepprg = "${lib.getExe pkgs.ripgrep} --vimgrep --no-heading --smart-case";
      undofile = true;
      # undodir = "~/.nvim_undo";
      foldnestmax = 2;
      foldlevel = 99;
      # completeopt = "menuone;noselect";
      scrolloff = 2;
    };
  };
}
