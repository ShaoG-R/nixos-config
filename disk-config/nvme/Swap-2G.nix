{ lib, disko, ... }:
{
  imports = [
    disko.nixosModules.disko
    ../boot.nix
  ];

  disko.devices.disk.main = {
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        # 1. ESP 分区：仅 64M，仅存放 GRUB 引导文件
        ESP = {
          priority = 1;
          size = "64M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/efi"; # 注意：挂载到 /boot/efi
            mountOptions = [ "defaults" ];
          };
        };

        # 2. Swap 分区：1G 固定大小
        # 因为这是独立的 Swap 分区，所以不需要 subvol=@swap 了
        swap = {
          priority = 2;
          size = "2G"; 
          content = {
            type = "swap";
            discardPolicy = "both"; # 允许 Swap 使用 discard/TRIM
            resumeDevice = true;    # 支持休眠恢复
          };
        };

        # 3. Root 分区：占据剩余的所有空间 (100%)
        root = {
          priority = 3;
          size = "100%";
          content = {
            type = "luks";
            name = "crypted";
            # NVMe 性能优化参数
            extraOpenArgs = [
              "--allow-discards"
              "--perf-no_read_workqueue"
              "--perf-no_write_workqueue"
            ];
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                # 根目录 (包含 /boot，因此内核会被压缩)
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
  };

  fileSystems."/var/log".neededForBoot = true;
}