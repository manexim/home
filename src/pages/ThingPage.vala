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

public class ThingPage : Granite.SimpleSettingsPage {
    private Lifx.LampController controller;

    public ThingPage (Models.Thing thing) {
        Object (
            activatable: true,
            icon_name: thing.icon,
            description: thing.id,
            title: thing.name != null ? thing.name : thing.id
        );

        controller = new Lifx.LampController ((Lifx.Lamp) thing);
        controller.updated.connect ((lamp) => {
            if (lamp.power == Power.ON) {
                status_switch.active = true;
                status_switch.state = true;
            } else if (lamp.power == Power.OFF) {
                status_switch.active = false;
                status_switch.state = false;
            }

            title = lamp.name;

            update_status ();
        });

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
        description = _("ID: ") + controller.lamp.id;
        description += "\n" + _("Manufacturer: ") + controller.lamp.manufacturer;
        description += "\n" + _("Model: ") + controller.lamp.model;

        switch (controller.lamp.power) {
        case Power.ON:
            status_type = Granite.SettingsPage.StatusType.SUCCESS;
            status = (_("Enabled"));
            break;
        case Power.OFF:
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
