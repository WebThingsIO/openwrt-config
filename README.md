To use the configuration file here:
```
git clone https://github.com/openwrt/openwrt
cd openwrt
make package/symlinks
cp ../APPROPRIATE-PATH/config.gateway.rpi .config
make defconfig
../APPROPRIATE-PATH/prep.sh
make -j4
```
