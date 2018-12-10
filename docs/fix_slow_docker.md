# Fixing slow Docker startup performance

The following hotfix is a permanent fix to the "slow Docker image" problem. Docker images may take a very long time to start due to intensive disk operations, caused by Docker using the `overlay` storage system. The `overlay` system used by Docker operates on a file-to-file basis, and while it provides better stability and compatibility, for performance reasons, it is preferable to use `devicemapper`.

These instructions **assumes** that you already have an additional premium SSD configured and attached to `/dev/sdc`, with an optimum size of 64GB)

These instructions are mainly compiled from `https://docs.docker.com/v1.13/engine/userguide/storagedriver/device-mapper-driver/`. Please make sure that you are running Docker version 1.13.X. If that's not the case, please contact the author to update this document.

1. Stop the Factotum subsystem with `$ sds stop factotum -f` from Mozart
2. Stop Docker on Factotum with `# systemctl stop docker`
3. Run `# pvcreate /dev/sdc` on Factotum to create an LVM on `/dev/sdc`. Please DOUBLE CHECK if you are creating the LVM on the right disk, creating on the wrong disk may result in PERMANENT DATA LOSS!
4. Run `# vgcreate docker /dev/sdc` to create a volume group called `docker`
5. Create a logical volume called `thinpool` for the data with `# lvcreate --wipesignatures y -n thinpool docker -l 95%VG`
6. Create a logical volume called `thinpoolmeta` for metadata with `# lvcreate --wipesignatures y -n thinpoolmeta docker -l 1%VG`
7. Convert the pool into a thin pool with `# lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta`
8. Configure the auto-extension of thin pools with

        tee /etc/lvm/profile/docker-thinpool.profile <<EOF
        activation {
        thin_pool_autoextend_threshold=80
        thin_pool_autoextend_percent=20
        }
        EOF

9. Apply the changes with `# lvchange --metadataprofile docker-thinpool docker/thinpool`
10. Backup your old Docker configurations and images with `mkdir /var/lib/docker.bk; mv /var/lib/docker/* /var/lib/docker.bk`
11. Modify `/etc/sysconfig/docker-storage`'s `DOCKER_STORAGE_OPTIONS` parameter to `--storage-driver=devicemapper --storage-opt=dm.thinpooldev=/dev/mapper/docker-thinpool --storage-opt=dm.use_deferred_removal=true --storage-opt=dm.use_deferred_deletion=true `
12. Modify `/etc/sysconfig/docker-storage-setup` to use `devicemapper` instead of `overlay`
13. Reload `systemctl` with `# systemctl daemon-reload`, and start docker with `# systemctl start docker`, and finally start Factotum from Mozart with `sds start factotum -f`
14. If all works well, you may want to delete the old version of your Docker images and configurations with `# rm -rf /var/lib/docker.bk`

To inspect the partitions thin pool, simply run `# lsblk`, and to query for the amount of storage used by Docker, simply use `$ docker info`
