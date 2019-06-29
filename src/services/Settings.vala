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

public class Settings : Granite.Services.Settings {
    private static Settings settings;
    private bool _is_freedesktop_prefers_color_scheme_available;

    public static Settings get_default () {
        if (settings == null) {
            settings = new Settings ();
        }

        return settings;
    }

    public string uuid { get; protected set; }
    public string last_started_app_version { get; set; }
    public string[] philips_hue_bridges { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public int window_x { get; set; }
    public int window_y { get; set; }
    public bool window_maximized { get; set; }

    private Settings () {
        base ("com.github.manexim.home");

        if (uuid == null || uuid == "") {
            uint8[] uu = new uint8[16];
            UUID.generate (uu);
            string s = "";

            for (uint8 i = 0; i < 16; i++) {
                s += uu[i].to_string ("%X");
            }

            uuid = s;
        }

        const string DESKTOP_SCHEMA = "org.freedesktop";
        const string PREFERS_KEY = "prefers-color-scheme";

        var lookup = SettingsSchemaSource.get_default ().lookup (DESKTOP_SCHEMA, false);
        if (lookup != null) {
            _is_freedesktop_prefers_color_scheme_available = true;

            var gtk_settings = Gtk.Settings.get_default ();
            var desktop_settings = new GLib.Settings (DESKTOP_SCHEMA);

            desktop_settings.bind_with_mapping (
                PREFERS_KEY,
                gtk_settings,
                "gtk-application-prefer-dark-theme",
                SettingsBindFlags.DEFAULT,
                (value, variant) => {
                    value.set_boolean (variant.get_string () == "dark");
                    return true;
                },
                (value, expected_type) => {
                    return new Variant.string(value.get_boolean() ? "dark" : "no-preference");
                },
                null,
                null
            );
        } else {
            _is_freedesktop_prefers_color_scheme_available = false;
        }
    }

    public void bind (string key, GLib.Object object, string property, GLib.SettingsBindFlags flags) {
        schema.bind (key, object, property, flags);
    }

    public bool is_first_run () {
        return last_started_app_version == "";
    }

    public bool is_freedesktop_prefers_color_scheme_available () {
        return _is_freedesktop_prefers_color_scheme_available;
    }

    public void save () {
        last_started_app_version = Config.APP_VERSION;

        var philips_hue_service = Philips.Hue.Service.instance;
        var bridges = philips_hue_service.bridges;

        var bridges_list = new Gee.ArrayList<string> ();
        for (uint i = 0; i < bridges.length; i++) {
            if (bridges[i].username != null) {
                size_t length;

                var gen = new Json.Generator ();
                var root = new Json.Node (Json.NodeType.OBJECT);
                var obj = new Json.Object ();
                root.set_object (obj);

                obj.set_string_member ("id", bridges[i].id);
                obj.set_string_member ("username", bridges[i].username);

                gen.set_root (root);
                bridges_list.add (gen.to_data (out length));
            }
        }

        philips_hue_bridges = bridges_list.to_array ();
    }
}
