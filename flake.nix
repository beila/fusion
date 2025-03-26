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
            packages = with pkgs;
                [
                    just
                    libllvm
                    lld
                    nim-unwrapped
                    qemu
                ];
            shellHook = ''
                nim -v
                clang --version
                ld.lld --version
                qemu-system-x86_64 --version
                '';
        };
    };
}
