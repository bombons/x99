# X99

Some automated scripts to setup a x99 hack. All scripts and procedure are based on the works of the legends RehabMan ans KGP.

## create CLOVER installer

```bash
./download.sh
```

## installation

```bash
./download.sh
./install_downloads.sh
```

### extra

By default FakeSMC sensors are not installed, if you want it run:

```bash
./install_sensors.sh
```

If you want only install tools:

```bash
./install_tools.sh
```

# commands

view non apple kexts loaded

```bash
kextstat | grep -v com.apple
```
