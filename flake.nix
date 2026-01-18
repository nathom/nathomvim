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
          ripgrep
          fd
          git
          stylua
          lazygit
        ];
        lsp = [
          universal-ctags
          stdenv.cc.cc
          nix-doc
          lua-language-server
          rust-analyzer
          pyright
          nixd
          ruff
        ];
        latex = [
          tex-fmt
        ];
        dashboard = [
          dwt1-shell-color-scripts
        ];
        kickstart-debug = [
          delve
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
          nvim-surround
          nvim-web-devicons
          plenary-nvim
          vim-wordmotion
          gruvbox-nvim
          mini-nvim
          nvim-treesitter
        ];
        kickstart-gitsigns = [
          gitsigns-nvim
        ];
      };

      optionalPlugins = with pkgs.vimPlugins; {
        lsp = [
          nvim-lspconfig
          lazydev-nvim
          fidget-nvim
          conform-nvim
          nvim-cmp
          luasnip
          cmp_luasnip
          cmp-nvim-lsp
          cmp-path
          todo-comments-nvim
        ];
        latex = [
          vimtex
          tabular
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

      python3.libraries = {};
      extraLuaPackages = {};
    };

    packageDefinitions = {
      # Full nvim with all features
      nvim = { pkgs, name, ... }: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = true;
          aliases = [ "vim" ];
        };
        categories = {
          general = true;
          lsp = true;
          latex = true;
          dashboard = true;

          customCore = true;
          customNavigation = true;
          customLsp = true;
          customLatex = true;
          customAi = true;

          kickstart-autopairs = true;
          kickstart-debug = true;
          kickstart-gitsigns = true;

          have_nerd_font = true;
        };
      };
      # Minimal nvim without LSP - fast startup
      nvim-min = { pkgs, name, ... }: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = true;
        };
        categories = {
          general = true;
          lsp = false;
          latex = false;
          dashboard = false;

          customCore = true;
          customNavigation = true;
          customLsp = false;
          customLatex = false;
          customAi = false;

          kickstart-autopairs = true;
          kickstart-debug = false;
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
