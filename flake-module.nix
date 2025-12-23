{
  lib,
  flake-parts-lib,
  inputs,
  ...
}:
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

          pkgsNameSeparator = mkOption {
            type = types.str;
            default = "/";
            description = ''
              The separator to use when flattening package names.
            '';
          };
        };
      }
    );
  };

  config = {
    perSystem =
      { config, pkgs, ... }:
      let
        flattenPkgs =
          separator: path: value:
          if lib.isDerivation value then
            {
              ${lib.concatStringsSep separator path} = value;
            }
          else if lib.isAttrs value then
            lib.concatMapAttrs (name: flattenPkgs separator (path ++ [ name ])) value
          else
            # Ignore the functions which makeScope returns
            { };

        inputsScope = lib.makeScope pkgs.newScope (self: {
          inherit inputs;
        });

        scopeFromDirectory =
          directory:
          lib.filesystem.packagesFromDirectoryRecursive {
            inherit directory;
            inherit (inputsScope) newScope callPackage;
          };

        legacyPackages = scopeFromDirectory config.pkgsDirectory;
      in
      lib.mkIf (config.pkgsDirectory != null) {
        inherit legacyPackages;
        packages = flattenPkgs config.pkgsNameSeparator [ ] legacyPackages;
      };
  };
}
