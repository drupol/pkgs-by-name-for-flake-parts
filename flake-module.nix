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
          else
            lib.concatMapAttrs (name: flattenPkgs separator (path ++ [ name ])) value;

        inputsScope = lib.makeScope pkgs.newScope (self: {
          inherit inputs;
        });

        scopeFromDirectory =
          directory:
          lib.filesystem.packagesFromDirectoryRecursive {
            inherit directory;
            inherit (inputsScope) newScope callPackage;
          };

        scope = scopeFromDirectory config.pkgsDirectory;

        # lib.makeScope takes two arguments:
        #   1. A newScope constructor (pkgs.newScope)
        #   2. A function (self: { packages... }) that builds the package set
        #
        # It returns a scope with helper functions AND a special `packages` attribute
        # that is the second function we passed in. By calling scope.packages with
        # scope itself as the argument, we:
        #   - Calculate the fixpoint (all packages can reference each other)
        #   - Extract just the packages attrset without helper functions (callPackage, etc.)
        #   - Avoid conflicts with the flake's top-level packages output
        #
        # Nix's laziness means this function call has no performance penalty.
        legacyPackages = scope.packages scope;
      in
      lib.mkIf (config.pkgsDirectory != null) {
        inherit legacyPackages;
        packages = flattenPkgs config.pkgsNameSeparator [ ] legacyPackages;
      };
  };
}
