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

public class Views.DevicesView : Gtk.Paned {
    private Gtk.Stack stack;
    private Controllers.DevicesController devices_controller;

    public DevicesView () {
        devices_controller = new Controllers.DevicesController ();

        stack = new Gtk.Stack ();

        var sidebar = new Granite.SettingsSidebar (stack);

        add (sidebar);
        add (stack);

        stack.add_named (new Pages.LoadingPage (), "loading");
        stack.show_all ();

        devices_controller.on_new_device.connect ((device) => {
            stack.add_named (new Pages.DevicePage (device), device.id);

            if (stack.get_visible_child_name () == "loading") {
                var child = stack.get_child_by_name ("loading");
                stack.remove (child);
            }

            stack.show_all ();
        });
    }
}
