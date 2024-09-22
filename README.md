[![Donate!][donate github]][5]

# pkgs-by-name for flake.parts

This project provides a [flake.parts] module that automatically loads Nix
packages from a specified directory. It transforms a directory tree containing
package files suitable for `callPackage` into a corresponding nested attribute
set of derivations.

For documentation and examples, please refer to the [manual].

## Usage

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

## TODO

- [ ] Automatically imports the discovered packages in the `pkgs` argument.

[flake.parts]: https://flake.parts
[5]: https://github.com/sponsors/drupol
[donate github]: https://img.shields.io/badge/Sponsor-Github-brightgreen.svg?style=flat-square
[manual]: https://nixos.org/manual/nixpkgs/stable/index.html#function-library-lib.filesystem.packagesFromDirectoryRecursive
