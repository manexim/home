# Home

## Installation

### Dependencies
These dependencies must be present before building
 - `meson (>=0.40)`
 - `valac (>=0.16)`
 - `libgtk-3-dev`
 - `libjson-glib-dev`
 - `libgee-0.8-dev`
 - `libgranite-dev`

### Building

```
git clone https://github.com/manexim/home.git && cd home
meson build && cd build
meson configure -Dprefix=/usr
ninja
sudo ninja install
com.github.manexim.home
```

### Deconstruct

```
sudo ninja uninstall
```
