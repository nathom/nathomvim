{ pkgs, ... }:
{

  extraPlugins = with pkgs.vimPlugins; [
    lazygit-nvim
  ];
  extraPackages = [ pkgs.lazygit ];

  extraConfigLua = ''
    require("telescope").load_extension("lazygit")
  '';

  keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<CR>";
      options = {
        desc = "LazyGit (root dir)";
      };
    }
  ];
}
