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

public class Pages.DevicePage : Granite.SimpleSettingsPage {
    private Controllers.DeviceController controller;

    public DevicePage (Models.Device device) {
        Object (
            activatable: true,
            icon_name: device.icon,
            description: device.id,
            title: device.name != null ? device.name : device.id
        );

        if (device is Lifx.Lamp) {
            controller = new Lifx.Controller (device);
        } else if (device is Philips.Hue.Lamp) {
            controller = new Philips.Hue.Controller (device);
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

        show_all ();
    }

    construct {
        var icon_button = new Gtk.Button ();
        icon_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        icon_button.set_image (new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.LARGE_TOOLBAR));

        icon_button.clicked.connect (() => {
            var icon_popover = new Widgets.IconPopover (icon_button);
            icon_popover.change_icon.connect ((name) => {
                controller.device.icon = name;
                icon_name = name;
                icon_button.set_image (new Gtk.Image.from_icon_name (name, Gtk.IconSize.LARGE_TOOLBAR));
            });
            icon_popover.show_all ();
        });

        content_area.attach (icon_button, 0, 0, 1, 1);
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
