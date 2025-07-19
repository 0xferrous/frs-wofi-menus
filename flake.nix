{
  description = "0xferrous' DeFiLlama menu utilities for wofi and rofi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        mkDflPackage = { script }: pkgs.stdenv.mkDerivation {
          pname = script;
          version = "0.1.0";

          src = ./.;

          installPhase = ''
            mkdir -p $out/bin $out/lib
            cp dfl-common.sh $out/lib/dfl-common.sh
            cp ${script} $out/bin/${script}
            chmod +x $out/bin/${script}
            
            # Update script path to use installed library location
            sed -i "s|source \"\$SCRIPT_DIR/dfl-common.sh\"|source \"$out/lib/dfl-common.sh\"|" $out/bin/${script}
          '';

          meta = with pkgs.lib; {
            description = "DeFiLlama protocol selector using ${script}";
            license = licenses.mit;
            platforms = platforms.linux;
          };
        };
      in
      {
        packages = {
          wofi-dfl-dir = mkDflPackage { script = "wofi-dfl-dir"; };
          rofi-dfl-dir = mkDflPackage { script = "rofi-dfl-dir"; };
          default = self.packages.${system}.rofi-dfl-dir;
        };
      });
}
