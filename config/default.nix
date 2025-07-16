_: {
  imports = [
    # General Configuration
    ./settings.nix
    ./keymaps.nix
    ./auto_cmds.nix

    # Themes
    ./plugins/themes

    # Completion
    ./plugins/cmp/cmp.nix
    ./plugins/cmp/autopairs.nix

    # Snippets
    ./plugins/snippets/luasnip.nix

    # Editor plugins and configurations
    ./plugins/editor/treesitter.nix

    # UI plugins
    ./plugins/ui/dressing.nix
    ./plugins/ui/oil.nix

    # LSP and formatting
    ./plugins/lsp/lsp.nix
    ./plugins/lsp/conform.nix

    # Git
    ./plugins/git/lazygit.nix
    # ./plugins/git/gitsigns.nix

    # Utils
    ./plugins/utils/telescope.nix
    ./plugins/utils/extra_plugins.nix
    ./plugins/utils/web-devicons.nix
  ];
}
