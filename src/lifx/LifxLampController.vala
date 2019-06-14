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

namespace Lifx {
    public class LifxLampController {
        private Lifx.Service service;
        private Lifx.LifxLamp _lamp;

        public signal void updated (Lifx.LifxLamp lamp);

        public LifxLampController (Lifx.LifxLamp lamp) {
            this._lamp = lamp;

            this.service = Lifx.Service.instance;
            this.service.onUpdatedThing.connect ((updatedLamp) => {
                if (updatedLamp.id == this.lamp.id) {
                    this.updated (updatedLamp as Lifx.LifxLamp);
                }
            });
        }

        public void switchPower (bool on) {
            this.service.setPower (this.lamp, on ? 65535 : 0);

            this._lamp.power = on ? Power.ON : Power.OFF;
        }

        public Lifx.LifxLamp lamp {
            get {
                return this._lamp;
            }
        }
    }
}
