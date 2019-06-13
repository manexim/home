public class Settings : Granite.Services.Settings {
    private static Settings settings;

    public static Settings get_default () {
        if (settings == null) {
            settings = new Settings ();
        }

        return settings;
    }

    public string last_started_app_version { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public int window_x { get; set; }
    public int window_y { get; set; }
    public bool window_maximized { get; set; }

    private Settings () {
        base ("com.github.manexim.home");

        const string DESKTOP_SCHEMA = "org.freedesktop";
        const string PREFERS_KEY = "prefers-color-scheme";

        var gtk_settings = Gtk.Settings.get_default ();
        var lookup = SettingsSchemaSource.get_default ().lookup (DESKTOP_SCHEMA, false);

        if (lookup != null) {
            var desktop_settings = new GLib.Settings (DESKTOP_SCHEMA);
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
    }

    public bool isFirstRun () {
        return last_started_app_version == "";
    }

    public void save () {
        last_started_app_version = Config.APP_VERSION;
    }
}
