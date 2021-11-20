/*
 * Copyright (c) 2021 Manexim (https://github.com/manexim)
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

public class Store : Flux.Store {
    public Gee.List<Models.Device> devices;

    public override void process (Flux.Action action) {
        switch (action.action_type) {
            case ActionType.ADD_DEVICE:
                process_add_device (action);
                break;
            case ActionType.UPDATE_DEVICE:
                process_update_device (action);
                break;
        }
    }

    private void process_add_device (Flux.Action action) {
        var payload = (DevicePayload) action.payload;

        var device = new Models.Device () {
            id = payload.id,
            name = payload.name,
            manufacturer = payload.manufacturer,
            model = payload.model,
            power = payload.power,
            icon = payload.icon,
            default_icon = payload.default_icon
        };

        devices.add (device);
    }

    private void process_update_device (Flux.Action action) {
        var payload = (DevicePayload) action.payload;

        for (int i = 0; i < devices.size; i++) {
            if (devices[i].id == payload.id) {
                devices[i] = new Models.Device () {
                    id = payload.id,
                    name = payload.name,
                    manufacturer = payload.manufacturer,
                    model = payload.model,
                    power = payload.power,
                    icon = payload.icon,
                    default_icon = payload.default_icon
                };

                break;
            }
        }
    }

    public Store () {
        devices = new Gee.ArrayList<Models.Device> ();
    }
}
