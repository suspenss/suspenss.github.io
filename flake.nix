{
  description = "ss's personal blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    meme = {
      url = "github:reuixiy/hugo-theme-meme";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, meme }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        blog = pkgs.stdenv.mkDerivation {
          name = "blog";
          # Exclude themes and public folder from build sources
          src = ./.;
          # Link theme to themes folder and build
          buildPhase = ''
            mkdir -p themes
            ln -s ${meme} themes/meme
            ls themes/meme/
            ${pkgs.hugo}/bin/hugo --minify
          '';

          installPhase = ''
            cp -r public $out
          '';

          meta = with pkgs.lib; {
            description = "ss's personal blog";
            platforms = platforms.all;
          };
        };
      in {
        packages = {
          blog = blog;
          default = blog;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ hugo ];
          # Link theme to themes folder
          shellHook = ''
            echo Hello
          '';
        };
      }
    );
}

