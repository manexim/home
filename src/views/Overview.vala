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

public class Overview : Gtk.Viewport {
    private ThingsController things_controller;

    public Overview () {
        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        add (scrolled_window);

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        scrolled_window.add (grid);

        var devices_label = new Gtk.Label (_("Devices"));
        devices_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        devices_label.xalign = 0;
        devices_label.margin_start = 10;

        var devices_carousel = new Carousel ();

        var devices_grid = new Gtk.Grid ();
        devices_grid.margin = 2;
        devices_grid.margin_top = 12;
        devices_grid.attach (devices_label, 0, 0, 1, 1);
        devices_grid.attach (devices_carousel, 0, 1, 1, 1);

        grid.attach (devices_grid, 0, 0, 1, 1);

        things_controller = new ThingsController ();
        things_controller.on_new_lamp.connect ((lamp) => {
            devices_carousel.add_thing (lamp);
        });

        things_controller.on_updated_lamp.connect ((lamp) => {
            devices_carousel.update_thing (lamp);
        });

        devices_carousel.on_thing_activated.connect ((thing) => {
            MainWindow.get_default ().go_to_page (
                new ThingPage (thing),
                (thing.name == null || thing.name.length == 0) ? thing.id : thing.name
            );
        });
    }
}
