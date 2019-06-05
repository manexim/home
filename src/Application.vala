public class MyApp : Granite.Application {
    private Gtk.Label label;

    public MyApp () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var window = new Gtk.ApplicationWindow (this);

        this.label = new Gtk.Label ("");
        window.add (label);

        var gtk_settings = Gtk.Settings.get_default ();

        var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
        mode_switch.primary_icon_tooltip_text = ("Light background");
        mode_switch.secondary_icon_tooltip_text = ("Dark background");
        mode_switch.valign = Gtk.Align.CENTER;
        mode_switch.bind_property ("active", gtk_settings, "gtk-application-prefer-dark-theme");

        var headerbar = new Gtk.HeaderBar ();
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.show_close_button = true;
        headerbar.pack_end (mode_switch);

        window.set_default_size (900, 600);
        window.set_size_request (750, 500);
        window.set_titlebar (headerbar);
        window.title = Config.APP_NAME;
        window.show_all ();
    }

    protected void addThing (Thing thing) {
        this.label.set_text (thing.id);
    }

    public static int main (string[] args) {
        var app = new MyApp ();

        var lifxService = new Lifx.Service (true);
        lifxService.onNewThing.connect ((thing) => {
            if (thing is Lamp) {
                print ("Found new lamp: ");
            } else {
                print ("Found new thing: ");
            }
            print ("%s\n", thing.id);

            app.addThing (thing);
        });

        lifxService.onUpdatedThing.connect ((thing) => {
            if (thing is Lamp) {
                print ("Updated lamp: ");
            } else {
                print ("Updated thing: ");
            }
            print ("%s\n", thing.id);

            app.addThing (thing);
        });

        return app.run (args);
    }
}
