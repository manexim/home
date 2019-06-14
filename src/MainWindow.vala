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

public class MainWindow : Gtk.ApplicationWindow {
    private Settings settings;

    public MainWindow (Gtk.Application application) {
        this.application = application;

        this.settings = Settings.get_default ();
        this.load_settings ();

        var headerbar = new Gtk.HeaderBar ();
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.show_close_button = true;

        this.set_titlebar (headerbar);
        this.title = Config.APP_NAME;

        var stack = new Gtk.Stack ();
        this.add (stack);

        if (settings.isFirstRun ()) {
            var welcomeView = new WelcomeView ();
            stack.add_named (welcomeView, "welcome");

            welcomeView.start.connect (() => {
                stack.set_visible_child_full("things", Gtk.StackTransitionType.SLIDE_LEFT);
            });
        }

        var thingsView = new ThingsView ();
        stack.add_named (thingsView, "things");

        this.delete_event.connect (() => {
            save_settings ();

            return false;
        });
    }

    private void load_settings () {
        if (settings.window_maximized) {
            this.maximize ();
            this.set_default_size (settings.window_width, settings.window_height);
        } else {
            this.set_default_size (settings.window_width, settings.window_height);
        }

        if (settings.window_x < 0 || settings.window_y < 0 ) {
            this.window_position = Gtk.WindowPosition.CENTER;
        } else {
            this.move (settings.window_x, settings.window_y);
        }
    }

    private void save_settings () {
        settings.window_maximized = this.is_maximized;

        if (!settings.window_maximized) {
            int x, y;
            this.get_position (out x, out y);
            settings.window_x = x;
            settings.window_y = y;

            int width, height;
            this.get_size (out width, out height);
            settings.window_width = width;
            settings.window_height = height;
        }

        settings.save ();
    }
}
