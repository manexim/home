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

public class Models.Lamp : Models.Device {
    public Lamp () {
        default_icon = "com.github.manexim.home.icon.lightbulb-symbolic";
    }

    public bool supports_brightness {
        get {
            if (!_obj.has_member ("supportsBrightness")) {
                supports_brightness = false;
            }

            return _obj.get_boolean_member ("supportsBrightness");
        }
        set {
            _obj.set_boolean_member ("supportsBrightness", value);
        }
    }

    public uint16 brightness_min {
        get {
            return (uint16) _obj.get_int_member ("brightnessMin");
        }
        set {
            _obj.set_int_member ("brightnessMin", value);
        }
    }

    public uint16 brightness_max {
        get {
            return (uint16) _obj.get_int_member ("brightnessMax");
        }
        set {
            _obj.set_int_member ("brightnessMax", value);
        }
    }

    public uint16 brightness {
        get {
            return (uint16) _obj.get_int_member ("brightness");
        }
        set {
            _obj.set_int_member ("brightness", value);
        }
    }

    public bool supports_color {
        get {
            if (!_obj.has_member ("supportsColor")) {
                supports_color = false;
            }

            return _obj.get_boolean_member ("supportsColor");
        }
        set {
            _obj.set_boolean_member ("supportsColor", value);
        }
    }

    public bool supports_color_temperature {
        get {
            if (!_obj.has_member ("supportsColorTemperature")) {
                supports_color_temperature = false;
            }

            return _obj.get_boolean_member ("supportsColorTemperature");
        }
        set {
            _obj.set_boolean_member ("supportsColorTemperature", value);
        }
    }

    public uint16 color_temperature_min {
        get {
            if (!_obj.has_member ("colorTemperatureMin")) {
                color_temperature_min = 0;
            }

            return (uint16) _obj.get_int_member ("colorTemperatureMin");
        }
        set {
            _obj.set_int_member ("colorTemperatureMin", value);
        }
    }

    public uint16 color_temperature_max {
        get {
            if (!_obj.has_member ("colorTemperatureMax")) {
                color_temperature_max = 0;
            }

            return (uint16) _obj.get_int_member ("colorTemperatureMax");
        }
        set {
            _obj.set_int_member ("colorTemperatureMax", value);
        }
    }

    public uint16 color_temperature {
        get {
            return (uint16) _obj.get_int_member ("colorTemperature");
        }
        set {
            _obj.set_int_member ("colorTemperature", value);
        }
    }

    public uint16 hue {
        get {
            return (uint16) _obj.get_int_member ("hue");
        }
        set {
            _obj.set_int_member ("hue", value);
        }
    }

    public uint16 saturation {
        get {
            return (uint16) _obj.get_int_member ("saturation");
        }
        set {
            _obj.set_int_member ("saturation", value);
        }
    }
}
