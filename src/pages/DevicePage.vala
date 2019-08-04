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

public class Pages.DevicePage : Pages.AbstractDevicePage {
    private Controllers.DeviceController controller;

    public DevicePage (Models.Device device) {
        Object (
            activatable: true,
            icon_name: device.icon,
            description: device.id,
            title: device.name != null ? device.name : device.id
        );

        if (device is Models.Lamp) {
            var lamp = device as Models.Lamp;

            if (lamp is Lifx.Lamp) {
                controller = new Lifx.Controller (lamp);
            } else if (lamp is Philips.Hue.Lamp) {
                controller = new Philips.Hue.Controller (lamp);
            }

            if (lamp.supports_color) {
                var hue_label = new Gtk.Label (_("Hue: "));
                hue_label.xalign = 1;

                var hue_scale = new Gtk.Scale.with_range (
                    Gtk.Orientation.HORIZONTAL, lamp.hue_min, lamp.hue_max, 1.0
                );

                hue_scale.adjustment.value = lamp.hue;
                hue_scale.hexpand = true;
                hue_scale.adjustment.value_changed.connect (() => {
                    #if DEMO_MODE
                    lamp.hue = (uint16) hue_scale.adjustment.value;
                    #else
                    controller.switch_hue ((uint16) hue_scale.adjustment.value);
                    #endif
                });

                content_area.attach (hue_label, 0, 0, 1, 1);
                content_area.attach (hue_scale, 1, 0, 1, 1);

                var saturation_label = new Gtk.Label (_("Saturation: "));
                saturation_label.xalign = 1;

                var saturation_scale = new Gtk.Scale.with_range (
                    Gtk.Orientation.HORIZONTAL, lamp.saturation_min, lamp.saturation_max, 1.0
                );

                saturation_scale.adjustment.value = lamp.saturation;
                saturation_scale.hexpand = true;
                saturation_scale.adjustment.value_changed.connect (() => {
                    #if DEMO_MODE
                    lamp.saturation = (uint16) saturation_scale.adjustment.value;
                    #else
                    controller.switch_saturation ((uint16) saturation_scale.adjustment.value);
                    #endif
                });

                content_area.attach (saturation_label, 0, 1, 1, 1);
                content_area.attach (saturation_scale, 1, 1, 1, 1);
            }

            if (lamp.supports_brightness) {
                var brightness_label = new Gtk.Label (_("Brightness: "));
                brightness_label.xalign = 1;

                var brightness_scale = new Gtk.Scale.with_range (
                    Gtk.Orientation.HORIZONTAL, lamp.brightness_min, lamp.brightness_max, 1.0
                );

                brightness_scale.adjustment.value = lamp.brightness;
                brightness_scale.hexpand = true;
                brightness_scale.adjustment.value_changed.connect (() => {
                    #if DEMO_MODE
                    lamp.brightness = (uint16) brightness_scale.adjustment.value;
                    #else
                    controller.switch_brightness ((uint16) brightness_scale.adjustment.value);
                    #endif
                });

                content_area.attach (brightness_label, 0, 2, 1, 1);
                content_area.attach (brightness_scale, 1, 2, 1, 1);
            }

            if (lamp.supports_color_temperature) {
                var color_temperature_label = new Gtk.Label (_("Color temperature: "));
                color_temperature_label.xalign = 1;

                var color_temperature_scale = new Gtk.Scale.with_range (
                    Gtk.Orientation.HORIZONTAL, lamp.color_temperature_min, lamp.color_temperature_max, 1.0
                );

                color_temperature_scale.adjustment.value = lamp.color_temperature;
                color_temperature_scale.hexpand = true;
                color_temperature_scale.adjustment.value_changed.connect (() => {
                    #if DEMO_MODE
                    lamp.color_temperature = (uint16) color_temperature_scale.adjustment.value;
                    #else
                    controller.switch_color_temperature ((uint16) color_temperature_scale.adjustment.value);
                    #endif
                });

                content_area.attach (color_temperature_label, 0, 3, 1, 1);
                content_area.attach (color_temperature_scale, 1, 3, 1, 1);
            }
        }

        controller.device.notify.connect (update_status);

        update_status ();

        status_switch.notify["active"].connect (update_status);

        status_switch.state_set.connect ((state) => {
            #if DEMO_MODE
            controller.device.power = state ? Types.Power.ON : Types.Power.OFF;
            #else
            controller.switch_power (state);
            #endif

            status_switch.active = state;
            status_switch.state = state;

            return state;
        });

        notify["icon-name"].connect (() => {
            device.icon = icon_name;
        });

        show_all ();
    }

    private void update_status () {
        description = _("ID: ") + controller.device.id;
        description += "\n" + _("Manufacturer: ") + controller.device.manufacturer;
        description += "\n" + _("Model: ") + controller.device.model;

        title = controller.device.name;

        switch (controller.device.power) {
        case Types.Power.ON:
            status_switch.active = true;
            status_switch.state = true;
            status_type = Granite.SettingsPage.StatusType.SUCCESS;
            status = (_("Enabled"));
            break;
        case Types.Power.OFF:
            status_switch.active = false;
            status_switch.state = false;
            status_type = Granite.SettingsPage.StatusType.OFFLINE;
            status = (_("Disabled"));
            break;
        default:
            status_type = Granite.SettingsPage.StatusType.NONE;
            status = (_("Unknown"));
            break;
        }
    }
}
