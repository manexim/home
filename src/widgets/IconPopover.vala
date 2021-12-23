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

public class Widgets.IconPopover : Gtk.Popover {
    public signal void change_icon (string name);

    public IconPopover (Gtk.Widget relative_to) {
        Object (
            modal: true,
            position: Gtk.PositionType.BOTTOM,
            relative_to: relative_to
        );
    }

    construct {
        var flow_box = new Gtk.FlowBox ();
        flow_box.expand = true;

        var icons = new Gee.ArrayList<string> ();

        var icon_theme = Gtk.IconTheme.get_default ();
        icon_theme.list_icons ("Applications").@foreach ((name) => {
            if (name.has_prefix ("com.manexim.home.icon")) {
                icons.add (name);
            }
        });

        foreach (string name in icons) {
            var icon_button = new Gtk.Button ();
            icon_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            icon_button.set_image (new Gtk.Image.from_icon_name (name, Gtk.IconSize.LARGE_TOOLBAR));

            icon_button.clicked.connect (() => {
                change_icon (name);
                destroy ();
            });

            flow_box.add (icon_button);
            flow_box.show_all ();
        }

        add (flow_box);
    }
}
