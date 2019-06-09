public class ThingsView : Gtk.Paned {
    private Gtk.Stack stack;
    private ThingsController thingsController;

    public ThingsView () {
        this.thingsController = new ThingsController ();

        this.stack = new Gtk.Stack ();

        var sidebar = new Granite.SettingsSidebar (stack);

        this.add (sidebar);
        this.add (stack);

        this.thingsController.onNewLamp.connect ((lamp) => {
            this.stack.add_named (new LampPage (lamp), lamp.id);
            this.stack.show_all ();
        });
    }
}
