# SH4 Cross compilation environment for MAG 250

Adapted from
https://tttapa.github.io/Pages/Raspberry-Pi/C++-Development/Building-The-Toolchain.html

Note that it is very difficult to just -v mapping the files on Windows and ditch the image building completely because crosstool-ng enforces strict file name cases.

## What it is?

SH4 Cross compilation environment for MAG 250 docker image!

My friend asked me if I can build a tiny C program for his Arduino pet project to be used on MAG250 TV set-top box which is quite old platform based on Renesas SH4 CPU and old Linux 2.6 environment with GLIBC 2.10, sure why not... 
Archeology is fun isn't it? So the first thing was that I haven't found any working tools, so in the process of hacking this stuff I made this docker image.

Fun facts discovered in the process:
- Because of environment restrictions I have to target GLIBC 2.10, the newest compiler that supports it is GCC 4.8.
- Stick with `libusb v1.0.22`, later versions requires C11 standard support which is not available in this setup
- In this build I used `crosstool-ng v1.20.0` which seems to be the oldest version that supports building GLIBC 2.10
- Some older downloads are moved to a new locations, luckily crosstool-ng can use already downloaded archives

The following text is for my client but you should be able to understand the commands.

---

Доп пакеты apt install: (при ручной установке)

> git cmake gcc flex bison bzip2 xz-utils unzip texinfo help2man wget file gawk libtool libtool-bin libncurses-dev 

```bash
docker build ./ctng -t sh4cc
```

Далее дорабатываем напильником конфиг кросс компилятора если потребуется
(идея взята с https://tttapa.github.io/Pages/Raspberry-Pi/C++-Development/Building-The-Toolchain.html)
```bash
# Rename the old configuration
cp /mnt/sh4-gcc48.config .config
# Upgrade the configuration
ct-ng upgradeconfig
# Customize the configuration
ct-ng menuconfig
# Overwrite the old configuration
cp .config /mnt/sh4-gcc48.config
exit
```

Кстати говоря исходный конфиг можно найти в `crosstool-ng/samples/sh4-unknown-linux-gnu/crosstool.config` 

В меню нужно будет настроить версии системы и библиотек, это уже сделано в версии в репозитории.

Реальная сборка контейнера который будет содержать компиляторы

```bash
docker build . --build-arg="NGCONFIG=sh4-gcc48.config" -t sh4builder
```

После ДОООООЛГОЙ сборки можно либо установить полученный тулчейн на своей линукс системе либо просто собирать в докере


## Используем полученный Docker образ с кросскомпилятором

Собираем в докере:

-  Качаем libusb и чекаутим в v1.0.22, в моем случае он будет находится в `D:/prog/cpp/libusb`


Для начала монтируем локальный пути для доступа из докера, также понадобится собрать libusb

```powershell
docker run -it --rm -v ${pwd}:/mnt/proj -v D:/prog/cpp/libusb:/mnt/libusb -v D:/prog/cpp/magtest/magtest:/mnt/magtest -t sh4builder bash
```

Большинство инструментов используют алиас CC в первую очередь и только потом ищут gcc в PATH, нам нужен именно наш кросс компилятор так что делаем так

```bash
export CC=/home/develop/x-tools/sh4-unknown-linux-gnu/bin/sh4-unknown-linux-gnu-gcc
```

Для сборки libusb придется отключить udev т.к. в старых ядрах его может тупо не быть

```bash
cd /mnt/libusb
mkdir build
cd build
../configure --host=x86_64-linux-gnu --target=sh4-unknown-linux-gnu --enable-udev=no --prefix=../.install
make
make install
```

Теперь можно собрать наш проект (пробный)

```bash
$CC -I/mnt/libusb/.install/include/libusb-1.0 main.c /mnt/libusb/.install/lib/libusb-1.0.a -std=c99 -lpthread -lrt -o testusb_sh4
```

с HTTP POST клиентом

```bash 
$CC -I/mnt/libusb/.install/include/libusb-1.0 /mnt/magtest/magtest.c /mnt/magtest/ip.h /mnt/magtest/ip.c /mnt/libusb/.install/lib/libusb-1.0.a -std=c99 -lpthread -lrt -o testusb011
```


Тут можно было бы сделать makefile или еще что, но из-за 2 файлов и 1 библиотеки не хочется возиться с этим.