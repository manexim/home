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

public class Lifx.Lamp : Models.Lamp {
    public Lamp () {
        default_icon = "com.manexim.home.icon.lightbulb.lifx-symbolic";
        manufacturer = "LIFX";

        supports_brightness = true;
        brightness_min = 0;
        brightness_max = 65535;

        supports_color_temperature = true;
        color_temperature_min = 2500;
        color_temperature_max = 9000;

        hue_min = 0;
        hue_max = 65535;

        saturation_min = 0;
        saturation_max = 65535;
    }

    public uint16 port {
        get {
            if (!_obj.has_member ("port")) {
                port = 56700;
            }

            return (uint16) _obj.get_int_member ("port");
        }
        set {
            _obj.set_int_member ("port", value);
        }
    }

    public bool supports_infrared {
        get {
            if (!_obj.has_member ("supportsInfrared")) {
                supports_infrared = false;
            }

            return _obj.get_boolean_member ("supportsInfrared");
        }
        set {
            _obj.set_boolean_member ("supportsInfrared", value);
        }
    }

    public bool supports_multizone {
        get {
            if (!_obj.has_member ("supportsMultizone")) {
                supports_multizone = false;
            }

            return _obj.get_boolean_member ("supportsMultizone");
        }
        set {
            _obj.set_boolean_member ("supportsMultizone", value);
        }
    }
}
