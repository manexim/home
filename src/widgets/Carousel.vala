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

public class Carousel : Gtk.FlowBox {
    private Gee.HashMap<string, int> carousel_item_map;
    private int index = 0;
    public signal void on_thing_activated (Models.Thing thing);

    public Carousel () {
        Object (
            activate_on_single_click: true,
            homogeneous: true
        );

        carousel_item_map = new Gee.HashMap<string, int> ();
    }

    construct {
        column_spacing = 12;
        row_spacing = 12;
        hexpand = true;
        max_children_per_line = 5;
        min_children_per_line = 2;
        selection_mode = Gtk.SelectionMode.NONE;
        child_activated.connect (on_child_activated);
    }

    public void add_thing (Models.Thing? thing) {
        var carousel_item = new CarouselItem (thing);
        add (carousel_item);
        carousel_item_map.set (thing.id, index++);
        show_all ();
    }

    public void update_thing (Models.Thing? thing) {
        weak Gtk.FlowBoxChild child = get_child_at_index (carousel_item_map.get (thing.id));
        if (child is CarouselItem) {
            var carousel_item = child as CarouselItem;
            carousel_item.update ();
        }
    }

    private void on_child_activated (Gtk.FlowBoxChild child) {
        if (child is CarouselItem) {
            var thing = ((CarouselItem)child).thing;
            on_thing_activated (thing);
        }
    }
}
