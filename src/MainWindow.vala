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
    private static MainWindow? instance;
    private Settings settings;
    private Gtk.Stack stack;
    private Gtk.Button return_button;
    private History history;
    private Widgets.Overlay overlay;

    public MainWindow (Gtk.Application application) {
        instance = this;

        history = new History ();

        this.application = application;

        settings = Settings.get_default ();
        load_settings ();

        var headerbar = new Gtk.HeaderBar ();
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.show_close_button = true;

        return_button = new Gtk.Button ();
        return_button.no_show_all = true;
        return_button.valign = Gtk.Align.CENTER;
        return_button.get_style_context ().add_class ("back-button");
        return_button.clicked.connect (go_back);
        headerbar.pack_start (return_button);

        if (!settings.is_freedesktop_prefers_color_scheme_available ()) {
            var gtk_settings = Gtk.Settings.get_default ();

            var mode_switch = new Granite.ModeSwitch.from_icon_name (
                "display-brightness-symbolic",
                "weather-clear-night-symbolic"
            );
            mode_switch.primary_icon_tooltip_text = _("Light background");
            mode_switch.secondary_icon_tooltip_text = _("Dark background");
            mode_switch.valign = Gtk.Align.CENTER;
            mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");
            settings.bind ("prefer-dark-style", mode_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            headerbar.pack_end (mode_switch);
        }

        set_titlebar (headerbar);
        title = Config.APP_NAME;

        overlay = Widgets.Overlay.instance;
        add (overlay);

        stack = new Gtk.Stack ();
        overlay.add (stack);

        if (settings.is_first_run ()) {
            var onboarding_view = new Views.OnboardingView ();
            stack.add_named (onboarding_view, "onboarding");

            onboarding_view.start.connect (() => {
                stack.set_visible_child_full (_("Overview"), Gtk.StackTransitionType.SLIDE_LEFT);
            });
        }

        var overview = new Views.Overview ();
        stack.add_named (overview, _("Overview"));
        history.add (_("Overview"));

        delete_event.connect (() => {
            save_settings ();

            return false;
        });
    }

    public static MainWindow get_default () {
        return instance;
    }

    public void go_to_page (Gtk.Widget page, string name) {
        stack.add_named (page, name);

        return_button.label = history.current;
        return_button.no_show_all = false;
        return_button.visible = true;
        history.add (name);
        stack.set_visible_child_full (name, Gtk.StackTransitionType.SLIDE_LEFT);
    }

    public void go_back () {
        if (!history.is_homepage) {
            var widget = stack.get_visible_child ();

            stack.set_visible_child_full (history.previous, Gtk.StackTransitionType.SLIDE_RIGHT);
            stack.remove (widget);

            history.pop ();
        }

        if (!history.is_homepage) {
            return_button.label = history.previous;
        } else {
            return_button.no_show_all = true;
            return_button.visible = false;
        }
    }

    private void load_settings () {
        if (settings.window_maximized) {
            maximize ();
            set_default_size (settings.window_width, settings.window_height);
        } else {
            set_default_size (settings.window_width, settings.window_height);
        }

        if (settings.window_x < 0 || settings.window_y < 0 ) {
            window_position = Gtk.WindowPosition.CENTER;
        } else {
            move (settings.window_x, settings.window_y);
        }
    }

    private void save_settings () {
        settings.window_maximized = is_maximized;

        if (!settings.window_maximized) {
            int x, y;
            get_position (out x, out y);
            settings.window_x = x;
            settings.window_y = y;

            int width, height;
            get_size (out width, out height);
            settings.window_width = width;
            settings.window_height = height;
        }

        settings.save ();
    }
}
