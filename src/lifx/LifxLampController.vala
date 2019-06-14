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
            _lamp = lamp;

            service = Lifx.Service.instance;
            service.on_updated_thing.connect ((updated_lamp) => {
                if (updated_lamp.id == lamp.id) {
                    updated ((Lifx.LifxLamp) updated_lamp);
                }
            });
        }

        public void switch_power (bool on) {
            service.set_power (lamp, on ? 65535 : 0);

            _lamp.power = on ? Power.ON : Power.OFF;
        }

        public Lifx.LifxLamp lamp {
            get {
                return _lamp;
            }
        }
    }
}
