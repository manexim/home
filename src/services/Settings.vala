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
    public string configuration { get; set; }
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
                    return new Variant.string (value.get_boolean () ? "dark" : "no-preference");
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
        #if DEMO_MODE
        return true;
        #endif

        return last_started_app_version == "";
    }

    public bool is_freedesktop_prefers_color_scheme_available () {
        return _is_freedesktop_prefers_color_scheme_available;
    }

    public Json.Object configuration_as_json () throws GLib.Error {
        var parser = new Json.Parser ();
        parser.load_from_data (configuration, -1);
        var object = parser.get_root ().get_object ();

        return object;
    }

    public void save () {
        #if DEMO_MODE
        return;
        #endif

        last_started_app_version = Config.APP_VERSION;

        var philips_hue_service = Philips.Hue.Service.instance;

        var obj = new Json.Object ();
        var com = new Json.Object ();
        var philips = new Json.Object ();
        var hue = new Json.Object ();
        var bridges = new Json.Object ();
        for (uint i = 0; i < philips_hue_service.bridges.length; i++) {
            if (philips_hue_service.bridges[i].username != null) {
                var bridge = new Json.Object ();
                bridge.set_string_member ("username", philips_hue_service.bridges[i].username);
                bridges.set_object_member (philips_hue_service.bridges[i].id, bridge);
            }
        }

        hue.set_object_member ("bridges", bridges);
        philips.set_object_member ("hue", hue);
        com.set_object_member ("philips", philips);
        obj.set_object_member ("com", com);

        var devices = new Json.Object ();
        foreach (var device in Controllers.DevicesController.instance.devices) {
            if (device.icon != device.default_icon) {
                var device_obj = new Json.Object ();
                device_obj.set_string_member ("icon", device.icon);
                devices.set_object_member (device.id, device_obj);
            }
        }
        obj.set_object_member ("devices", devices);

        var gen = new Json.Generator ();
        var root = new Json.Node (Json.NodeType.OBJECT);
        root.set_object (obj);
        gen.set_root (root);

        size_t length;
        configuration = gen.to_data (out length);
    }
}
