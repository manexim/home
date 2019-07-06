/*
* Copyright (c) 2019 Manexim (https://github.com/manexim)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public abstract class Controllers.DeviceController : Object {
    protected Models.Device _device;

    public DeviceController (Models.Device device) {
        Object (
            device : device
        );
    }

    public abstract void switch_hue (uint16 hue);

    public abstract void switch_saturation (uint16 saturation);

    public abstract void switch_brightness (uint16 brightness);

    public abstract void switch_color_temperature (uint16 color_temperature);

    public abstract void switch_power (bool on);

    public Models.Device device {
        get {
            return _device;
        }
        construct set {
            _device = value;
        }
    }
}
