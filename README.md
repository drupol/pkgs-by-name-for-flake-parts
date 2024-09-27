[![Donate!][donate github]][5]

# pkgs-by-name for flake.parts

This project provides a [flake.parts] module that automatically loads Nix
packages from a specified directory. It transforms a directory tree containing
package files suitable for `callPackage` into a corresponding nested attribute
set of derivations.

For documentation and examples, please refer to the [manual].

## Installation

The structure of the directory containing the packages
is the same structure as the `pkgs/by-name` directory from `nixpkgs`.

The first step is to import the input.

```nix
    inputs = {
        pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    };
```

Then, import the module:

```nix
    imports = [
        inputs.pkgs-by-name-for-flake-parts.flakeModule
    ];
```

Then configure the module:

```nix
    perSystem = {
        pkgsDirectory = ./nix/pkgs;
    };
```

## Usage

Once the module is configured, it does two things.

1. It builds the `packages` attribute of your flake by flattening the tree
   structure of your filesystem (specified in the `pkgsDirectory` attribute)
   into a flat list of packages.
2. It builds a `legacyPackages` attribute in your flake, allowing you to access
   the packages using the same hierarchical structure as the package directory
   specified in the `pkgsDirectory` attribute.

[flake.parts]: https://flake.parts
[5]: https://github.com/sponsors/drupol
[donate github]: https://img.shields.io/badge/Sponsor-Github-brightgreen.svg?style=flat-square
[manual]: https://nixos.org/manual/nixpkgs/stable/index.html#function-library-lib.filesystem.packagesFromDirectoryRecursive
