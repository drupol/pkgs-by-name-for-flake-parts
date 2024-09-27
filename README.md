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

Once the module is configured, it does two things:

1. It builds the Flake's `packages` attribute by recursively traversing the
   directory specified in the `pkgsDirectory` attribute. This directory,
   which may have a nested tree structure, is transformed into a flat list of
   packages. Each package is named by concatenating its relative directory path
   from `pkgsDirectory` to the package itself.
2. It builds the Flake's `legacyPackages` attribute by allowing you to access
   the packages using the same hierarchical structure as the package directory
   specified in the `pkgsDirectory` attribute. This means you can reference
   packages as if they were still organized in the original tree structure.

## Configuration

This module has the following configuration attributes:

- `pkgsDirectory`: The directory containing the packages. This directory
  should contain a tree of Nix files suitable for `callPackage`. The default
  value is `null`.
- `pkgsNameSeparator`: The separator used to concatenate the package name. The
  default value is `/`.

[flake.parts]: https://flake.parts
[5]: https://github.com/sponsors/drupol
[donate github]: https://img.shields.io/badge/Sponsor-Github-brightgreen.svg?style=flat-square
[manual]: https://nixos.org/manual/nixpkgs/stable/index.html#function-library-lib.filesystem.packagesFromDirectoryRecursive
