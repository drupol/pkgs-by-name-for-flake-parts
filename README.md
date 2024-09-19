[![Donate!][donate github]][5]

# pkgs-by-name for flake.parts

This project is a module for [flake.parts], a framework for Nix flakes.

It provides a module that can be used to autoload packages under a particular
directory and make them available in your own flake.

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
