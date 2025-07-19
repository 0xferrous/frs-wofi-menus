{
  description = "0xferrous' wofi menu utilities";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            pname = "wofi-dfl-dir";
            version = "0.1.0";

            src = ./.;

            installPhase = ''
              mkdir -p $out/bin
              cp wofi-dfl-dir $out/bin/wofi-dfl-dir
              chmod +x $out/bin/wofi-dfl-dir
            '';

            meta = with pkgs.lib; {
              description = "0xferrous' wofi menu utilities";
              license = licenses.mit;
              platforms = platforms.linux;
            };
          };
          wofi-dfl-dir = self.packages.${system}.default;
        };
      });
}
