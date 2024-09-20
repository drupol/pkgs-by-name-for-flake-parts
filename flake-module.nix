toplevel@{ lib, flake-parts-lib, inputs, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption
    ;
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {
    perSystem = mkPerSystemOption (
      { ... }:
      {
        options = {
          pkgsDirectory = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = ''
              If set, the flake will import packages from the specified directory.
            '';
          };
        };
      }
    );
  };

  config = {
    perSystem =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        packages =
          let
            scope = lib.makeScope pkgs.newScope (self: {
              inherit inputs;
            });
          in
          lib.optionalAttrs (config.pkgsDirectory != null) (
            lib.filesystem.packagesFromDirectoryRecursive {
              inherit (scope) callPackage;
              directory = config.pkgsDirectory;
            }
          );
      };
  };
}
