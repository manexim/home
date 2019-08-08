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

public class Views.Overview : Gtk.ScrolledWindow {
    private Controllers.DevicesController devices_controller;
    private Gtk.Stack stack;
    private Gtk.Grid network_view;
    private Gtk.Grid grid;

    public Overview () {
        var network_alert_view = new Granite.Widgets.AlertView (_("Network Is Not Available"),
                                                            _("Connect to the network to control your smart home gadgets."),
                                                            "network-error");
        network_alert_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        network_alert_view.show_action (_("Network Settings…"));

        network_view = new Gtk.Grid ();
        network_view.margin = 24;
        network_view.attach (network_alert_view, 0, 0, 1, 1);

        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        grid = new Gtk.Grid ();
        grid.margin = 12;

        stack.add (grid);
        stack.add (network_view);

        add (stack);

        var loading_revealer = new Gtk.Revealer ();
        loading_revealer.add (new Pages.LoadingPage ());
        loading_revealer.reveal_child = true;

        grid.attach (loading_revealer, 0, 0, 1, 1);

        var devices_label = new Gtk.Label (_("Devices"));
        devices_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        devices_label.xalign = 0;
        devices_label.margin_start = 10;

        var devices_carousel = new Widgets.Carousel ();

        var devices_grid = new Gtk.Grid ();
        devices_grid.margin = 2;
        devices_grid.margin_top = 12;
        devices_grid.attach (devices_label, 0, 0, 1, 1);
        devices_grid.attach (devices_carousel, 0, 1, 1, 1);

        var devices_revealer = new Gtk.Revealer ();
        devices_revealer.add (devices_grid);

        grid.attach (devices_revealer, 0, 1, 1, 1);

        devices_controller = Controllers.DevicesController.instance;
        devices_controller.on_new_device.connect ((device) => {
            if (loading_revealer.child_revealed) {
                loading_revealer.reveal_child = false;
            }

            devices_carousel.add_thing (device);
            devices_revealer.reveal_child = true;
        });

        devices_controller.on_updated_device.connect ((device) => {
            devices_carousel.update_thing (device);
        });

        devices_carousel.on_thing_activated.connect ((thing) => {
            MainWindow.get_default ().go_to_page (
                new Pages.DevicePage (thing as Models.Device),
                (thing.name == null || thing.name.length == 0) ? thing.id : thing.name
            );
        });

        var hubs_label = new Gtk.Label (_("Hubs"));
        hubs_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        hubs_label.xalign = 0;
        hubs_label.margin_start = 10;

        var hubs_carousel = new Widgets.Carousel ();

        var hubs_grid = new Gtk.Grid ();
        hubs_grid.margin = 2;
        hubs_grid.margin_top = 12;
        hubs_grid.attach (hubs_label, 0, 0, 1, 1);
        hubs_grid.attach (hubs_carousel, 0, 1, 1, 1);

        var hubs_revealer = new Gtk.Revealer ();
        hubs_revealer.add (hubs_grid);

        grid.attach (hubs_revealer, 0, 2, 1, 1);

        var philipsHueService = Philips.Hue.Service.instance;
        philipsHueService.on_new_bridge.connect ((bridge) => {
            if (loading_revealer.child_revealed) {
                loading_revealer.reveal_child = false;
            }

            hubs_carousel.add_thing (bridge);
            hubs_revealer.reveal_child = true;
        });

        hubs_carousel.on_thing_activated.connect ((thing) => {
            if (thing.power != Types.Power.ON) {
                MainWindow.get_default ().go_to_page (
                    new Pages.HueBridgeOnboardingPage (thing as Philips.Hue.Bridge),
                    (thing.name == null || thing.name.length == 0) ? thing.id : thing.name
                );
            }
        });

        NetworkMonitor.get_default ().network_changed.connect (on_view_mode_changed);

        network_alert_view.action_activated.connect (() => {
            try {
                AppInfo.launch_default_for_uri ("settings://network", null);
            } catch (Error e) {
                warning (e.message);
            }
        });
    }

    private void on_view_mode_changed () {
        var connection_available = NetworkMonitor.get_default ().get_network_available ();
        if (!connection_available) {
            stack.visible_child = network_view;
        } else {
            stack.visible_child = grid;
        }
    }
}
