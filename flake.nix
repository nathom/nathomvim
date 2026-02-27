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
          lazygit
        ];
        # Language-specific toolchains
        lang-lua = [
          lua-language-server
          stylua
        ];
        lang-python = [
          pyright
          ruff
        ];
        lang-rust = [
          rust-analyzer
        ];
        lang-nix = [
          nixd
          nix-doc
        ];
        lang-go = [
          gopls
          delve
        ];
        lang-haskell = [
          haskell-language-server
        ];
        lang-c = [
          clang-tools
        ];
        # Feature-specific
        latex = [
          tex-fmt
        ];
        dashboard = [
          dwt1-shell-color-scripts
        ];
        ctags = [
          universal-ctags
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
          # Base treesitter with common parsers
          (nvim-treesitter.withPlugins (p: [
            p.bash p.markdown p.vim p.vimdoc p.diff
          ]))
        ];
        # Language-specific treesitter parsers
        lang-lua = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (p: [ p.lua p.luadoc ]))
        ];
        lang-python = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (p: [ p.python ]))
        ];
        lang-rust = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (p: [ p.rust p.toml ]))
        ];
        lang-nix = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (p: [ p.nix ]))
        ];
        lang-go = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (p: [ p.go p.gomod p.gosum ]))
        ];
        lang-haskell = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (p: [ p.haskell ]))
        ];
        lang-c = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (p: [ p.c p.cpp ]))
        ];
        kickstart-gitsigns = [
          gitsigns-nvim
        ];
      };

      optionalPlugins = with pkgs.vimPlugins; {
        # Core LSP infrastructure (needed if any lang is enabled)
        lsp-core = [
          nvim-lspconfig
          fidget-nvim
          conform-nvim
          nvim-cmp
          luasnip
          cmp_luasnip
          cmp-nvim-lsp
          cmp-path
          todo-comments-nvim
        ];
        # Language-specific plugins
        lang-lua = [
          lazydev-nvim
        ];
        lang-go = [
          nvim-dap
          nvim-dap-ui
          nvim-nio
          nvim-dap-virtual-text
        ];
        lang-python = [
          nvim-dap
          nvim-dap-ui
          nvim-nio
          nvim-dap-virtual-text
        ];
        latex = [
          vimtex
          tabular
        ];
        autopairs = [
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

    # Helper to create package with selected languages
    mkNvimPackage = { langs ? [], extras ? {} }: { pkgs, name, ... }: {
      settings = {
        suffix-path = true;
        suffix-LD = true;
        wrapRc = true;
        aliases = [ "nvim" "nathomvim" ];
      };
      categories = {
        general = true;
        dashboard = extras.dashboard or false;
        latex = extras.latex or false;
        ctags = extras.ctags or false;
        autopairs = extras.autopairs or true;
        kickstart-gitsigns = true;

        # LSP core enabled if any language is selected
        lsp-core = (builtins.length langs) > 0;

        # Language categories
        lang-lua = builtins.elem "lua" langs;
        lang-python = builtins.elem "python" langs;
        lang-rust = builtins.elem "rust" langs;
        lang-nix = builtins.elem "nix" langs;
        lang-go = builtins.elem "go" langs;
        lang-haskell = builtins.elem "haskell" langs;
        lang-c = builtins.elem "c" langs;

        # Lua plugin categories
        customCore = true;
        customNavigation = true;
        customLsp = (builtins.length langs) > 0;
        customLatex = extras.latex or false;
        customAi = extras.ai or false;

        have_nerd_font = true;
      };
    };

    packageDefinitions = {
      # Full nvim with all languages (default)
      nvim = mkNvimPackage {
        langs = [ "lua" "python" "rust" "nix" "go" "haskell" ];
        extras = { dashboard = true; latex = true; ai = true; ctags = true; };
      };

      # Minimal - no LSP, fast startup
      nvim-min = mkNvimPackage {
        langs = [];
        extras = {};
      };

      # Ari: Python + Go + Rust + C/C++
      ari = mkNvimPackage {
        langs = [ "python" "go" "rust" "c" ];
        extras = { dashboard = true; ai = true; };
      };

      # Anduril: Haskell + Python + Rust + Nix
      anduril = mkNvimPackage {
        langs = [ "haskell" "python" "rust" "nix" ];
        extras = { dashboard = true; ai = true; };
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
