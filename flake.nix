{
    description="Fusion";
    inputs={
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    outputs={nixpkgs,...}: let
        system = "aarch64-darwin";
        pkgs = import nixpkgs { inherit system; };
    in {
        devShells.${system}.simple = pkgs.mkShell {
            packages = [pkgs.just];
            shellHook = ''
                ${pkgs.just}/bin/just
            '';
        };
    };
}
