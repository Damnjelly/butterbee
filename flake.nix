{
  description = "A Nix-flake-based Gleam development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages =
              let
                dependencies = with pkgs; [
                  erlang_27
                  rebar3
                ];

                runtimeDependencies = with pkgs; [
                  firefox
                  servo
                  chromium
                ];

                devDependencies = with pkgs; [
                  gleam
                  erlang-language-platform
                  typescript-language-server
                  nixd
                  nixfmt
                  typos-lsp
                  marksman
                ];
              in
              dependencies ++ runtimeDependencies ++ devDependencies;
          };
        }
      );
    };
}
