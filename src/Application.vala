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
