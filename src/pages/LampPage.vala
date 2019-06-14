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

public class LampPage : Granite.SimpleSettingsPage {
    private Lifx.LifxLampController controller;

    public LampPage (Lamp lamp) {
        Object (
            activatable: true,
            icon_name: "com.github.manexim.home.lightbulb.lifx-symbolic",
            description: lamp.id,
            title: lamp.name != null ? lamp.name : lamp.id
        );

        this.controller = new Lifx.LifxLampController (lamp as Lifx.LifxLamp);
        this.controller.updated.connect ((lamp) => {
            if (lamp.power == Power.ON) {
                this.status_switch.active = true;
                this.status_switch.state = true;
            } else if (lamp.power == Power.OFF) {
                this.status_switch.active = false;
                this.status_switch.state = false;
            }

            this.title = lamp.name;

            updateStatus ();
        });

        updateStatus ();

        status_switch.notify["active"].connect (updateStatus);

        status_switch.state_set.connect ((state) => {
            this.controller.switchPower (state);

            this.status_switch.active = state;
            this.status_switch.state = state;

            return state;
        });
    }

    private void updateStatus () {
        this.description = "ID: " + this.controller.lamp.id;
        this.description += "\nManufacturer: " + this.controller.lamp.manufacturer;
        this.description += "\nModel: " + this.controller.lamp.model;

        switch (this.controller.lamp.power) {
        case Power.ON:
            status_type = Granite.SettingsPage.StatusType.SUCCESS;
            status = ("Enabled");
            break;
        case Power.OFF:
            status_type = Granite.SettingsPage.StatusType.OFFLINE;
            status = ("Disabled");
            break;
        default:
            status_type = Granite.SettingsPage.StatusType.NONE;
            status = ("Unknown");
            break;
        }
    }
}
