{
  description = "Forest SDDM Theme";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        default = pkgs.stdenvNoCC.mkDerivation {
          pname = "my-sddm-theme";
          version = "1.0";

          src = self;

          propagatedBuildInputs = [ pkgs.qt6.qtmultimedia ];

          installPhase = ''
            mkdir -p $out/share/sddm/themes/forest-sddm-theme
            cp -r ./* $out/share/sddm/themes/forest-sddm-theme/
          '';
        };
      });
  };
}
