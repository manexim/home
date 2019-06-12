public class MainWindow : Gtk.ApplicationWindow {
    private Settings settings;

    public MainWindow (Gtk.Application application) {
        this.application = application;

        this.settings = Settings.get_default ();
        this.load_settings ();

        var thingsView = new ThingsView ();
        this.add (thingsView);

        var headerbar = new Gtk.HeaderBar ();
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.show_close_button = true;

        this.set_titlebar (headerbar);
        this.title = Config.APP_NAME;

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
    }
}
