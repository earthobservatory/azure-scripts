# Fixing slow Docker startup performance

## New version

The new version uses the latest version of Docker, `docker-ce`, instead of the legacy Docker versions. Please make sure that your cluster is provisioned with the latest Puppets or that `docker-ce` was [retrofitted](https://docs.docker.com/install/linux/docker-ce/centos/) to an existing system running an older version of docker.

The following hotfix permanently fixes the slow Docker container spin up issues by taking advantage of the [temporary disk](https://blogs.msdn.microsoft.com/mast/2013/12/06/understanding-the-temporary-drive-on-windows-azure-virtual-machines/) (AWS equivalent: ephemeral disk) available on every Azure VM instance that has much higher IOPS and throughput than any Managed Disk (AWS equivalent: EBS). Docker container spin up takes roughly the same time as AWS after applying this fix.

This fix forces the Factotum instance to use the VM's temporary disk. If the instance has a very large temporary disk (> 150GB), the script will partition 50GB for Docker and the rest for `/data`. Else, the script will dedicate the entire temporary disk to Docker.

1. (Optional) Stop HySDS from Mozart by running `sds stop all -f` on Mozart
2. Install `docker-ephemeral-lvm` from the [Azure adaptation of `puppet-autoscale`](https://github.com/earthobservatory/puppet-autoscale/tree/azure-beta1):
    - Copy `templates/docker-ephemeral-lvm.service` into `/etc/systemd/system/docker-ephemeral-service.d`, create the folder if required
    - Copy `templates/docker-ephemeral-lvm.sh` into `/etc/systemd/system/docker-ephemeral-service.d`
3. Verify that the script works: `sudo systemctl start docker-ephemeral-lvm`, verify that the service has started and exited properly and that `docker info` now shows the correct device being used
4. Enable the service to run on startup: `sudo systemctl enable docker-ephemeral-lvm`

However, a caveat of this approach is that both Docker images and `/data` (if the instance's temporary disk is big enough) will be purged following a reboot, requiring the Docker images to be pulled from the code bucket when running new jobs on a freshly rebooted Factotum instance.

## Legacy version

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

    ```bash
    tee /etc/lvm/profile/docker-thinpool.profile <<EOF
    activation {
    thin_pool_autoextend_threshold=80
    thin_pool_autoextend_percent=20
    }
    EOF
    ```

9. Apply the changes with `# lvchange --metadataprofile docker-thinpool docker/thinpool`
10. Backup your old Docker configurations and images with `mkdir /var/lib/docker.bk; mv /var/lib/docker/* /var/lib/docker.bk`
11. Modify `/etc/sysconfig/docker-storage`'s `DOCKER_STORAGE_OPTIONS` parameter to `--storage-driver=devicemapper --storage-opt=dm.thinpooldev=/dev/mapper/docker-thinpool --storage-opt=dm.use_deferred_removal=true --storage-opt=dm.use_deferred_deletion=true`
12. Modify `/etc/sysconfig/docker-storage-setup` to use `devicemapper` instead of `overlay`
13. Reload `systemctl` with `# systemctl daemon-reload`, and start docker with `# systemctl start docker`, and finally start Factotum from Mozart with `sds start factotum -f`
14. If all works well, you may want to delete the old version of your Docker images and configurations with `# rm -rf /var/lib/docker.bk`

To inspect the partitions thin pool, simply run `# lsblk`, and to query for the amount of storage used by Docker, simply use `$ docker info`
