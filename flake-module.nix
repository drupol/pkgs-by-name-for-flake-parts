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
        scope = lib.makeScope pkgs.newScope (self: {
          inherit inputs;
        });

        flattenAttrs =
          {
            attrs ? { },
            separator ? "/",
            callback,
          }:
          let
            flatten =
              attrSet: prefixes:
              builtins.foldl' (
                acc: name:
                let
                  newValue = attrSet.${name};
                  newKey = prefixes ++ [ name ];
                in
                if lib.isFunction newValue then
                  acc // { ${lib.concatStringsSep separator newKey} = newValue callback; }
                else
                  acc // (flatten newValue newKey)

              ) { } (builtins.attrNames attrSet);
          in
          flatten attrs [ ];
      in
      lib.mkIf (config.pkgsDirectory != null) {
        legacyPackages = lib.filesystem.packagesFromDirectoryRecursive {
          directory = config.pkgsDirectory;
          inherit (scope) callPackage;
        };

        packages = flattenAttrs {
          attrs = lib.filesystem.packagesFromDirectoryRecursive {
            directory = config.pkgsDirectory;
            callPackage =
              file: args: callback:
              callback file args;
          };
          separator = config.pkgsNameSeparator;
          callback = scope.callPackage;
        };
      };
  };
}
