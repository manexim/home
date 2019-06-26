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

public class DevicesController {
    private Lifx.Service lifx_service;
    private Philips.Hue.Service philips_hue_service;

    public signal void on_new_lamp (Models.Lamp lamp);
    public signal void on_updated_lamp (Models.Lamp lamp);

    public DevicesController () {
        lifx_service = Lifx.Service.instance;

        lifx_service.on_new_device.connect ((device) => {
            on_new_lamp((Models.Lamp) device);
        });

        lifx_service.on_updated_device.connect ((device) => {
            on_updated_lamp((Models.Lamp) device);
        });

        philips_hue_service = Philips.Hue.Service.instance;

        philips_hue_service.on_new_device.connect ((device) => {
            on_new_lamp((Models.Lamp) device);
        });

        philips_hue_service.on_updated_device.connect ((device) => {
            on_updated_lamp((Models.Lamp) device);
        });
    }
}
