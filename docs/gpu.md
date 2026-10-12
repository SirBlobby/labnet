# GPU

ARC and ASRC have NVIDIA GPUs and set `GPU_VENDOR=nvidia`.

## Setup

1. Install the NVIDIA driver by hand and reboot
2. Check that `nvidia-smi` works
3. Run `install.sh`, which installs the NVIDIA Container Toolkit and adds the `nvidia` runtime to Docker

## Using the GPU in a stack

```yaml
services:
  example:
    image: nvidia/cuda:12.6.0-base-ubuntu24.04
    command: nvidia-smi
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities:
                - gpu
```

To use one GPU, replace `count: all` with `device_ids: ["0"]`.

## Driver updates

`update.sh` upgrades apt packages, which can include the NVIDIA driver. The new driver only loads after a reboot, and GPU containers can fail until then. Reboot when `update.sh` warns that a reboot is required.

To stop automatic driver upgrades:

```
sudo apt-mark hold 'nvidia-driver-*' 'libnvidia-*'
```

## Troubleshooting

| Problem                                 | Check                                              |
|-----------------------------------------|----------------------------------------------------|
| `could not select device driver "nvidia"` | `docker info \| grep -i runtime` should list nvidia, rerun `install.sh` |
| `Failed to initialize NVML`             | Driver and library mismatch, reboot                |
| `nvidia-smi` not found on host          | Driver is not installed                            |
