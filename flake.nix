{
  description = "My NixOS Flake Library";

  inputs = {
    # 基础依赖 (用于定义 module 系统)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # 外部模块依赖
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
  };

  outputs = { self, nixpkgs, disko, nixos-facter-modules, ... }@inputs: {
    # 1. 导出所有模块为一个聚合入口
    nixosModules = {
      default = { config, pkgs, lib, ... }: {
        imports = [
          nixos-facter-modules.nixosModules.facter
          disko.nixosModules.disko
          
          ./modules/app/default.nix
          ./modules/base/default.nix
          ./modules/hardware/default.nix
        ];
      };
      
      # 2. 细分导出 - 内核优化模块（通过子 Flake 独立管理）
      # [黑魔法] builtins.getFlake 在模块函数内部调用，延迟评估
      # ${./path} 将目录放入 Nix Store，保证纯净性
      # 子 Flake 拥有独立的 flake.lock，与根目录完全隔离
      kernel-cachyos = { ... }: {
        imports = [
          (builtins.getFlake "${./modules/kernel/cachyos}").nixosModules.default
        ];
      };
      kernel-cachyos-unstable = { ... }: {
        imports = [
          (builtins.getFlake "${./modules/kernel/cachyos-unstable}").nixosModules.default
        ];
      };
      kernel-xanmod = ./modules/kernel/xanmod.nix;
    };
  };
}