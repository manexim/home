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

public class Controllers.DevicesController {
    private static DevicesController? _instance;
    private Lifx.Service lifx_service;
    private Philips.Hue.Service philips_hue_service;

    private Gee.ArrayList<Models.Device> device_list;
    private Gee.HashMap<string, Models.Device> device_loaded_map;

    public signal void on_new_device (Models.Device device);
    public signal void on_updated_device (Models.Device device);

    public static DevicesController instance {
        get {
            if (_instance == null) {
                _instance = new DevicesController ();
            }

            return _instance;
        }
    }

    private DevicesController () {
        device_list = new Gee.ArrayList<Models.Device> ();
        load_devices ();

        lifx_service = Lifx.Service.instance;

        lifx_service.on_new_device.connect ((device) => {
            if (device_loaded_map.has_key (device.id)) {
                device.icon = device_loaded_map.get (device.id).icon;
            }

            Actions.add_device (device.id, device.name, device.manufacturer, device.model, device.power.to_string (), device.icon, device.default_icon);

            on_new_device (device);

            device_list.add (device);
        });

        lifx_service.on_updated_device.connect ((device) => {
            Actions.update_device (device.id, device.name, device.manufacturer, device.model, device.power.to_string (), device.icon, device.default_icon);

            on_updated_device (device);
        });

        philips_hue_service = Philips.Hue.Service.instance;

        philips_hue_service.on_new_device.connect ((device) => {
            if (device_loaded_map.has_key (device.id)) {
                device.icon = device_loaded_map.get (device.id).icon;
            }

            Actions.add_device (device.id, device.name, device.manufacturer, device.model, device.power.to_string (), device.icon, device.default_icon);

            on_new_device (device);

            device_list.add (device);
        });

        philips_hue_service.on_updated_device.connect ((device) => {
            Actions.update_device (device.id, device.name, device.manufacturer, device.model, device.power.to_string (), device.icon, device.default_icon);

            on_updated_device (device);
        });
    }

    public Models.Device[] devices {
        owned get {
            return device_list.to_array ();
        }
    }

    private void load_devices () {
        device_loaded_map = new Gee.HashMap<string, Models.Device> ();

        try {
            var configuration = Settings.get_default ().configuration_as_json ();
            Json.Object o;
            if (configuration.has_member ("devices")) {
                o = configuration.get_object_member ("devices");
            } else {
                return;
            }

            foreach (var key in o.get_members ()) {
                var obj = o.get_object_member (key);
                if (obj == null) {
                    continue;
                }

                var device = new Models.Device.from_object (obj);
                device.id = key;

                device_loaded_map.set (device.id, device);
            }
        } catch (Error e) {
            stderr.printf (e.message);
        }
    }
}
