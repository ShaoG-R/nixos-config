{ swapSize }:
{ lib, config, pkgs, disko, diskDevice ? "/dev/sda", ... }:
let
  imageSize = "${toString (swapSize + 3072)}M";
in
{
  imports = [
    disko.nixosModules.disko
    ./boot.nix
  ];

  disko.devices.disk.main = {
    # 这里指定生成的 raw 文件初始大小。
    inherit imageSize;

    device = diskDevice;
    content = {
      type = "gpt";
      partitions = {
        # 为了在 BIOS+GPT 上启动
        boot = {
          priority = 0;
          size = "1M";
          type = "EF02"; 
        };
        # 1. ESP 分区
        ESP = {
          priority = 1;
          size = "32M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/efi";
            mountOptions = [ "defaults" ];
          };
        };

        # 2. Swap 分区
        swap = {
          priority = 2;
          size = "${toString swapSize}M";
          content = {
            type = "swap";
            discardPolicy = "both";
            resumeDevice = true;
          };
        };

        # 3. Root 分区 (直接使用 Btrfs，移除 LUKS 加密层)
        root = {
          priority = 3;
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = [ "compress-force=zstd:3" "noatime" "space_cache=v2" ];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = [ "compress-force=zstd:3" "noatime" "space_cache=v2" ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [ "compress-force=zstd:3" "noatime" "space_cache=v2" ];
              };
              "@log" = {
                mountpoint = "/var/log";
                mountOptions = [ "compress-force=zstd:3" "noatime" "space_cache=v2" ];
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/var/log".neededForBoot = true;

  # 启动时自动修复 GPT 分区表并扩容最后一个分区
  boot.growPartition = true;

  # 针对 Btrfs 根分区的自动扩容配置
  fileSystems."/".autoResize = true;

  # 确保必要的工具在系统路径中 (cloud-utils 包含 growpart)
  environment.systemPackages = [ pkgs.cloud-utils ];
}
