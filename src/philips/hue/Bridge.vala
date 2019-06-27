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

public class Philips.Hue.Bridge : Models.Device {
    public Bridge () {
        icon = "com.github.manexim.home.bridge.philips.hue-symbolic";
        manufacturer = "Philips";
        power = Types.Power.WARNING;
    }

    public Bridge.from_object (Json.Object object) {
        _obj = object;
    }

    public string base_url {
        get {
            if (!_obj.has_member ("baseURL")) {
                base_url = null;
            }

            return _obj.get_string_member ("baseURL");
        }
        set {
            _obj.set_string_member ("baseURL", value);
        }
    }

    public string username {
        get {
            if (!_obj.has_member ("username")) {
                username = null;
            }

            return _obj.get_string_member ("username");
        }
        set {
            _obj.set_string_member ("username", value);
        }
    }
}
