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

public class ThingsController {
    private Lifx.Service lifxService;

    public signal void onNewLamp(Lamp lamp);
    public signal void onUpdatedLamp(Lamp lamp);

    public ThingsController () {
        this.lifxService = Lifx.Service.instance;

        this.lifxService.onNewThing.connect ((thing) => {
            this.onNewLamp(thing as Lamp);
        });

        this.lifxService.onUpdatedThing.connect ((thing) => {
            this.onUpdatedLamp(thing as Lamp);
        });
    }
}
