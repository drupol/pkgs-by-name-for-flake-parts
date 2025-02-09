[![Donate!][donate github]][5]

# pkgs-by-name for flake.parts

This project provides a [flake.parts] module that automatically loads Nix
packages from a specified directory via [packagesFromDirectoryRecursive]. It
transforms a directory tree containing package files suitable for `callPackage`
into a corresponding attribute set of derivations that conforms to the Flake
standard.

## Installation

The structure of the directory containing the packages
is the same structure as the `pkgs/by-name` directory from `nixpkgs`.

The first step is to add this module as an input to your flake.

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

and configure it:

```nix
  perSystem = {
    pkgsDirectory = ./nix/pkgs;
  };
```

## Usage

Once the module is configured, it does two things:

1. It transforms the directory tree of `pkgsDirectory` into a nested attribute
   set of derivations via [packagesFromDirectoryRecursive].
   This set is made available as the Flake's `legacyPackages` attribute. You can
   read more about the expected folder structure at the link above.
2. To conform to the Flake standards, this set is then flattened. Each
   derivation is assigned its path as a name, with the separator being
   configurable.

- You can access flake inputs from package files by adding an `inputs`
  parameter, it will be automatically populated with a set containing all your
  inputs.
- You can access all other packages you have defined in this folder or its
  subfolders:
  - If it's a top-level package, add its name to your package's parameters.
  - If it's a package in a subfolder, add the top-level folder's name to your
    package's parameters.

## Configuration

This module has the following configuration attributes:

- `pkgsDirectory`: The directory containing the packages. This directory
  should contain a tree of Nix files suitable for `callPackage`. The default
  value is `null`.
- `pkgsNameSeparator`: The separator used to concatenate the package name. The
  default value is `/`.

## Example

Given this `flake.nix` file:

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    # Some non-flake sources for our packages
    example-src = {
      url = "github:ghost/example";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    imports = [
      inputs.pkgs-by-name-for-flake-parts.flakeModule
    ];
    perSystem = { ... }: {
      pkgsDirectory = ./packages;
    };
  };
}

```

In this given directory structure:

```
.
├── flake.lock
├── flake.nix
└── packages
    ├── pkg1
    │   └── package.nix
    └── subdirectory
        └── pkg2.nix
```

`pkg1` depends on `pkg2`:

```nix
# ./packages/pkg1/package.nix
{ stdenv, dir }:
stdenv.mkDerivation {
  name = "pkg1";
  # `subdirectory` contains all packages in the folder `packages/subdirectory`
  buildInputs = [ subdirectory.pkg2 ];
}
```

`pkg2` depends on an input:

```nix
# ./packages/subdirectory/pkg2.nix
{ stdenv, inputs }:
stdenv.mkDerivation {
  name = "pkg2";
  src = inputs.example-src;
}
```

Note how this package does not have its own directory. You can have either
`<package name>/package.nix`, or `<package name>.nix`. The former is useful if
you want to split the package into multiple nix files.


This is the structure of the resulting flake outputs:

```
outputs
├───legacyPackages
│   ├───aarch64-darwin
│   │   ├───pkg1: package 'pkg1'
│   │   └───subdirectory
│   │       └───pkg2: package 'pkg2'
│   ├───aarch64-linux
│   │   ├───pkg1: package 'pkg1'
│   │   └───subdirectory
│   │       └───pkg2: package 'pkg2'
│   ├───x86_64-darwin
│   │   ├───pkg1: package 'pkg1'
│   │   └───subdirectory
│   │       └───pkg2: package 'pkg2'
│   └───x86_64-linux
│       ├───pkg1: package 'pkg1'
│       └───subdirectory
│           └───pkg2: package 'pkg2'
└───packages
    ├───aarch64-darwin
    │   ├───pkg1: package 'pkg1'
    │   └───"subdirectory/pkg2": package 'pkg2'
    ├───aarch64-linux
    │   ├───pkg1: package 'pkg1'
    │   └───"subdirectory/pkg2": package 'pkg2'
    ├───x86_64-darwin
    │   ├───pkg1: package 'pkg1'
    │   └───"subdirectory/pkg2": package 'pkg2'
    └───x86_64-linux
        ├───pkg1: package 'pkg1'
        └───"subdirectory/pkg2": package 'pkg2'
```

[flake.parts]: https://flake.parts
[5]: https://github.com/sponsors/drupol
[donate github]: https://img.shields.io/badge/Sponsor-Github-brightgreen.svg?style=flat-square
[packagesFromDirectoryRecursive]: https://nixos.org/manual/nixpkgs/stable/index.html#function-library-lib.filesystem.packagesFromDirectoryRecursive
