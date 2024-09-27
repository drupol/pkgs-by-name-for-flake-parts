toplevel@{
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
      let
        scope = lib.makeScope pkgs.newScope (self: {
          inherit inputs;
        });

        flattenAttrs =
          attrSet: cp:
          let
            flatten =
              attrSet: prefix:
              builtins.foldl' (
                acc: name:
                let
                  value = attrSet.${name};
                  newKey = if prefix == "" then name else "${prefix}/${name}";
                in
                if lib.isFunction value then acc // { ${newKey} = value cp; } else acc // (flatten value newKey)
              ) { } (builtins.attrNames attrSet);
          in
          flatten attrSet "";
      in
      {
        legacyPackages = lib.optionalAttrs (config.pkgsDirectory != null) (
          lib.filesystem.packagesFromDirectoryRecursive {
            directory = config.pkgsDirectory;
            inherit (scope) callPackage;
          }
        );

        packages = lib.optionalAttrs (config.pkgsDirectory != null) (
          flattenAttrs (lib.filesystem.packagesFromDirectoryRecursive {
            directory = config.pkgsDirectory;
            callPackage =
              file: args: cp:
              cp file args;
          }) scope.callPackage
        );
      };
  };
}
