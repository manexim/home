public class MyApp : Gtk.Application {
    private Gtk.Label label;

    public MyApp () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this);
        main_window.default_height = 480;
        main_window.default_width = 640;
        main_window.title = Config.APP_NAME;

        this.label = new Gtk.Label ("");
        main_window.add (label);

        main_window.show_all ();
    }

    protected void addLamp (string lamp) {
        this.label.set_text (lamp);
    }

    public static int main (string[] args) {
        var app = new MyApp ();

        var lifxService = new Lifx.Service ();
        lifxService.onNewLamp.connect ((lamp) => {
            print ("Found new lamp: %s\n", lamp);

            app.addLamp (lamp);
        });

        return app.run (args);
    }
}
