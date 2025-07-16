{ pkgs, lib, ... }:
{
  extraPlugins =
    with pkgs.vimPlugins;
    [
       (pkgs.vimUtils.buildVimPlugin {
          name = "feline";
          src = pkgs.fetchFromGitHub {
              owner = "famiu";
              repo = "feline.nvim";
              rev = "3587f57480b88e8009df7b36dc84e9c7ff8f2c49";
              hash = "sha256-u9TY9DrjDgBYJYG8RJtU+ZqFjsi2YknV2R6rL+ISb/M=";
          };
          doCheck = false;
          dependencies = [vim-gitbranch];
      })

    (pkgs.vimUtils.buildVimPlugin {
      name = "sayonara";
      src = pkgs.fetchFromGitHub {
          owner = "mhinz";
          repo = "vim-sayonara";
          rev = "75c73f3cf3e96f8c09db5291970243699aadc02c";
          hash = "sha256-R/NrlXJHdo5GrwztPGXogh9tRGA9WTRtwb96JqitDPY=";
      };
      doCheck = false;
    })


      (pkgs.vimUtils.buildVimPlugin {
          name = "diffstatus";
          src = pkgs.fetchFromGitHub {
              owner = "nathom";
              repo = "diffstatus.nvim";
              rev = "d4850f22233b772faa24c1f2110f2318805a6aa7";
              hash = "sha256-A/cD5eNYmF9DCNiAjASHBB/SvDTYwaNVmQD/p5u0Y6o=";
          };
          doCheck = false;
          dependencies = [];
      })
    ];
  extraFiles."lua/feline_config.lua".text = lib.fileContents ../../lua/feline.lua;
  extraConfigLua = ''require("feline_config")'';
}
