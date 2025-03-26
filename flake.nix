{
    description="Fusion";
    inputs={
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    outputs={nixpkgs,...}: let
        system = "aarch64-darwin";
        pkgs = import nixpkgs {
            inherit system;
            config = {
                # Package ‘OVMF-202411’ is marked as broken, refusing to evaluate.
                allowBroken = true;
            };
        };
    in {
        devShells.${system}.simple = pkgs.mkShell {
            packages = with pkgs;
                [
                    OVMF
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
