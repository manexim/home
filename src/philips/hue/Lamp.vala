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

public class Philips.Hue.Lamp : Models.Lamp {
    public Philips.Hue.Bridge bridge;

    public Lamp () {
        default_icon = "com.manexim.home.icon.lightbulb.philips.hue-symbolic";
        manufacturer = "Philips";

        brightness_min = 0;
        brightness_max = 254;

        hue_min = 0;
        hue_max = 65535;

        saturation_min = 0;
        saturation_max = 254;
    }

    public string number {
        get {
            if (!_obj.has_member ("number")) {
                number = null;
            }

            return _obj.get_string_member ("number");
        }
        set {
            _obj.set_string_member ("number", value);
        }
    }
}
