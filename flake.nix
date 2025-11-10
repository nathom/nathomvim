{
  description = "the nathomvim config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = { self, nixpkgs, nixCats, ... }@inputs: let
    inherit (nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
    };

    dependencyOverlays = [ (utils.standardPluginOverlay inputs) ];

    categoryDefinitions = { pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: {
      lspsAndRuntimeDeps = with pkgs; {
        general = [
          universal-ctags
          ripgrep
          fd
          git
          dwt1-shell-color-scripts
          stdenv.cc.cc
          nix-doc
          lua-language-server
          rust-analyzer
          bash
          pyright
          tex-fmt
          nixd
          ruff
          stylua
          lazygit
          zsh
        ];
        kickstart-debug = [
          delve
        ];
        kickstart-lint = [
          markdownlint-cli
        ];
      };

      startupPlugins = with pkgs.vimPlugins; {
        general = [
          vim-sleuth
          vim-sayonara
          snacks-nvim
          lazy-nvim
          vim-cool
          flash-nvim
          which-key-nvim
          comment-nvim
          oil-nvim
          gitsigns-nvim
          nvim-surround
          nvim-web-devicons
          plenary-nvim
          nvim-lspconfig
          lazydev-nvim
          fidget-nvim
          conform-nvim
          nvim-cmp
          luasnip
          vim-wordmotion
          cmp_luasnip
          cmp-nvim-lsp
          cmp-path
          gruvbox-nvim
          todo-comments-nvim
          mini-nvim
          vimtex
          (nvim-treesitter.withPlugins (
            plugins: with plugins; [
              nix
              lua
              python
              rust
            ]
          ))
        ];
        kickstart-debug = [
          nvim-dap
          nvim-dap-ui
          nvim-nio
          nvim-dap-virtual-text
        ];
        kickstart-autopairs = [
          nvim-autopairs
        ];
      };

      optionalPlugins = {};

      sharedLibraries = {
        general = with pkgs; [
          libgit2
        ];
      };

      environmentVariables = let
        localeArchive =
          if pkgs.stdenv.hostPlatform.isLinux then
            "${pkgs.glibcLocales}/lib/locale/locale-archive"
          else
            null;
      in {
        general =
          {
            LANG = "en_US.UTF-8";
            LC_ALL = "en_US.UTF-8";
          }
          // pkgs.lib.optionalAttrs (localeArchive != null) {
            LOCALE_ARCHIVE = localeArchive;
          };
      };

      extraWrapperArgs = {
      };

      python3.libraries = {
        test = (_:[]);
      };
      extraLuaPackages = {
        test = [ (_:[]) ];
      };
    };

    packageDefinitions = {
      nvim = { pkgs, name, ... }: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = true;
          aliases = [ "vim" ];
          hosts.python3.enable = true;
          hosts.node.enable = true;
        };
        categories = {
          general = true;
          gitPlugins = true;
          customPlugins = true;
          customCore = true;
          customNavigation = true;
          customLsp = true;
          customLatex = true;
          customAi = true;
          test = false;

          kickstart-autopairs = true;
          kickstart-debug = true;
          kickstart-lint = false;

          kickstart-gitsigns = true;

          have_nerd_font = true;
        };
      };
    };
    defaultPackageName = "nvim";
  in

  forEachSystem (system: let
    nixCatsBuilder = utils.baseBuilder luaPath {
      inherit nixpkgs system dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions;
    defaultPackage = nixCatsBuilder defaultPackageName;
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages = utils.mkAllWithDefault defaultPackage;

    devShells = {
      default = pkgs.mkShell {
        name = defaultPackageName;
        packages = [ defaultPackage ];
        inputsFrom = [ ];
        shellHook = ''
        '';
      };
    };

  }) // (let
    nixosModule = utils.mkNixosModules {
      moduleNamespace = [ defaultPackageName ];
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
    homeModule = utils.mkHomeModules {
      moduleNamespace = [ defaultPackageName ];
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
  in {

    overlays = utils.makeOverlays luaPath {
      inherit nixpkgs dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions defaultPackageName;

    nixosModules.default = nixosModule;
    homeModules.default = homeModule;

    inherit utils nixosModule homeModule;
    inherit (utils) templates;
  });
}
