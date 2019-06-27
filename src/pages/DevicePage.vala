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
        }

        controller.device.notify.connect (update_status);

        update_status ();

        status_switch.notify["active"].connect (update_status);

        status_switch.state_set.connect ((state) => {
            controller.switch_power (state);

            status_switch.active = state;
            status_switch.state = state;

            return state;
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
