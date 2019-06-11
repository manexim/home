public class Application : Granite.Application {
    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var window = new Gtk.ApplicationWindow (this);

        var thingsView = new ThingsView ();
        window.add (thingsView);

        var gtk_settings = Gtk.Settings.get_default ();

        var headerbar = new Gtk.HeaderBar ();
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.show_close_button = true;

        window.set_default_size (900, 600);
        window.set_size_request (750, 500);
        window.set_titlebar (headerbar);
        window.title = Config.APP_NAME;

        const string DESKTOP_SCHEMA = "org.freedesktop";
        const string PREFERS_KEY = "prefers-color-scheme";

        var lookup = SettingsSchemaSource.get_default ().lookup (DESKTOP_SCHEMA, false);

        if (lookup != null) {
            var desktop_settings = new Settings (DESKTOP_SCHEMA);
            desktop_settings.bind_with_mapping (
                PREFERS_KEY,
                gtk_settings,
                "gtk-application-prefer-dark-theme",
                SettingsBindFlags.DEFAULT,
                (value, variant) => {
                    value.set_boolean (variant.get_string () == "dark");
                    return true;
                },
                (value, expected_type) => {
                    return new Variant.string(value.get_boolean() ? "dark" : "no-preference");
                },
                null,
                null
            );
        }

        window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Application ();

        return app.run (args);
    }
}
