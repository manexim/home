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

public class Overview : Gtk.ScrolledWindow {
    private DevicesController devices_controller;

    public Overview () {
        var grid = new Gtk.Grid ();
        grid.margin = 12;
        add (grid);

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

        var devices_revealer = new Gtk.Revealer ();
        devices_revealer.add (devices_grid);

        grid.attach (devices_revealer, 0, 0, 1, 1);

        devices_controller = new DevicesController ();
        devices_controller.on_new_lamp.connect ((lamp) => {
            devices_carousel.add_thing (lamp);
            devices_revealer.reveal_child = true;
        });

        devices_controller.on_updated_lamp.connect ((lamp) => {
            devices_carousel.update_thing (lamp);
        });

        devices_carousel.on_thing_activated.connect ((thing) => {
            MainWindow.get_default ().go_to_page (
                new DevicePage (thing),
                (thing.name == null || thing.name.length == 0) ? thing.id : thing.name
            );
        });

        var hubs_label = new Gtk.Label (_("Hubs"));
        hubs_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        hubs_label.xalign = 0;
        hubs_label.margin_start = 10;

        var hubs_carousel = new Carousel ();

        var hubs_grid = new Gtk.Grid ();
        hubs_grid.margin = 2;
        hubs_grid.margin_top = 12;
        hubs_grid.attach (hubs_label, 0, 0, 1, 1);
        hubs_grid.attach (hubs_carousel, 0, 1, 1, 1);

        var hubs_revealer = new Gtk.Revealer ();
        hubs_revealer.add (hubs_grid);

        grid.attach (hubs_revealer, 0, 1, 1, 1);

        var philipsHueService = Philips.Hue.Service.instance;
        philipsHueService.on_new_bridge.connect ((bridge) => {
            hubs_carousel.add_thing (bridge);
            hubs_revealer.reveal_child = true;
        });

        hubs_carousel.on_thing_activated.connect ((thing) => {
            MainWindow.get_default ().go_to_page (
                new HueBridgeOnboardingPage (thing as Philips.Hue.Bridge),
                (thing.name == null || thing.name.length == 0) ? thing.id : thing.name
            );
        });
    }
}
