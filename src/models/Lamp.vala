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

namespace Models {
    public class Lamp : Thing {
        public Power power {
            get {
                if (!_obj.has_member ("power")) {
                    _obj.set_string_member ("power", "unknown");
                }

                switch (_obj.get_string_member ("power")) {
                    case "on":
                        return Power.ON;
                    case "off":
                        return Power.OFF;
                    default:
                        return Power.UNKNOWN;
                }
            }
            set {
                _obj.set_string_member ("power", value.to_string ());
            }
        }

        public string manufacturer {
            get {
                if (!_obj.has_member ("manufacturer")) {
                    manufacturer = null;
                }

                return _obj.get_string_member ("manufacturer");
            }
            set {
                _obj.set_string_member ("manufacturer", value);
            }
        }

        public string model {
            get {
                if (!_obj.has_member ("model")) {
                    model = null;
                }

                return _obj.get_string_member ("model");
            }
            set {
                _obj.set_string_member ("model", value);
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
    }
}
