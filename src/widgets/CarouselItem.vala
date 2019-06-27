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

public class CarouselItem : Gtk.FlowBoxChild {
    public Models.Thing thing { get; construct set; }
    private Gtk.Image icon;
    private Gtk.Image status_icon;
    private Gtk.Label name_label;
    private Gtk.Label id_label;

    public CarouselItem (Models.Thing thing) {
        Object (thing: thing);
    }

    construct {
        icon = new Gtk.Image ();
        icon.pixel_size = 64;

        status_icon = new Gtk.Image ();
        status_icon.halign = Gtk.Align.END;
        status_icon.valign = Gtk.Align.END;
        status_icon.pixel_size = 16;

        var icon_overlay = new Gtk.Overlay ();
        icon_overlay.width_request = 64;
        icon_overlay.add (icon);
        icon_overlay.add_overlay (status_icon);

        name_label = new Gtk.Label (thing.name);
        name_label.valign = Gtk.Align.END;
        name_label.xalign = 0;
        name_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        id_label = new Gtk.Label (thing.id);
        id_label.valign = Gtk.Align.START;
        id_label.xalign = 0;
        id_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 3;
        grid.margin = 6;
        grid.attach (icon_overlay, 0, 0, 1, 2);
        grid.attach (name_label, 1, 0, 1, 1);
        grid.attach (id_label, 1, 1, 1, 1);

        add (grid);

        update ();

        thing.notify.connect (update);
    }

    public void update () {
        icon.gicon = new ThemedIcon (thing.icon);

        switch (thing.power) {
        case Power.ON:
            status_icon.icon_name = "user-available";
            break;
        case Power.OFF:
            status_icon.icon_name = "user-offline";
            break;
        case Power.WARNING:
            status_icon.icon_name = "user-away";
            break;
        default:
            status_icon.icon_name = "dialog-question";
            break;
        }

        name_label.label = thing.name;
        id_label.label = thing.id;
    }
}
