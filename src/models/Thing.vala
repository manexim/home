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

public class Thing {
    protected Json.Object _obj;

    public Thing () {
        _obj = new Json.Object ();
    }

    public string id {
        get {
            if (!_obj.has_member ("id")) {
                id = null;
            }

            return _obj.get_string_member ("id");
        }
        set {
            _obj.set_string_member ("id", value);
        }
    }

    public string name {
        get {
            if (!_obj.has_member ("name")) {
                name = null;
            }

            return _obj.get_string_member ("name");
        }
        set {
            _obj.set_string_member ("name", value);
        }
    }

    public string to_string () {
        size_t length;

        var gen = new Json.Generator ();
        var root = new Json.Node (Json.NodeType.OBJECT);
        root.set_object (_obj);
        gen.set_root (root);

        return gen.to_data (out length);
    }
}
