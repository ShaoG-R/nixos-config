# Kernel 分区的 flake-parts 模块
# 定义 kernel-cachyos 和 kernel-cachyos-unstable NixOS 模块
{ inputs, ... }:

{
  # 导出 NixOS 模块到 flake.nixosModules
  flake.nixosModules = {
    # CachyOS 稳定版内核
    kernel-cachyos = {
      imports = [
        # 从分区的 extraInputs 获取 chaotic
        inputs.chaotic.nixosModules.nyx-cache
        inputs.chaotic.nixosModules.nyx-overlay
        inputs.chaotic.nixosModules.nyx-registry
        ./cachyos/default.nix
      ];
    };

    # CachyOS 不稳定版内核
    kernel-cachyos-unstable = {
      imports = [
        # unstable 使用完整的 chaotic.nixosModules.default
        inputs.chaotic.nixosModules.default
        ./cachyos-unstable/default.nix
      ];
    };

    # Xanmod 内核（无需 chaotic）
    kernel-xanmod = ./xanmod.nix;
  };
}
