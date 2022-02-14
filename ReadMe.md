# mpvz

Qt5/QML based GUI for libmpv. Based on the Tethys theme for [Bomi](http://bomi-player.github.io/).

`mpvz https://www.youtube.com/watch?v=j_aDGFXNfyw`

![](https://i.imgur.com/57u3fcf.png)


## Compile and Install

```bash
## Install Dependencies
# Arch / Manjaro
sudo pacman -S git make gcc mpv

# Download Source Code
git clone https://github.com/Zren/mpvz.git
cd mpvz

## Compile and Install
mkdir -p build
cd build
qmake ..
make
sudo make install
```

