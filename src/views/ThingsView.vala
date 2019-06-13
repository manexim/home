public class ThingsView : Gtk.Paned {
    private Gtk.Stack stack;
    private ThingsController thingsController;

    public ThingsView () {
        this.thingsController = new ThingsController ();

        this.stack = new Gtk.Stack ();

        var sidebar = new Granite.SettingsSidebar (stack);

        this.add (sidebar);
        this.add (stack);

        this.stack.add_named (new LoadingPage (), "loading");
        this.stack.show_all ();

        this.thingsController.onNewLamp.connect ((lamp) => {
            this.stack.add_named (new LampPage (lamp), lamp.id);

            if (this.stack.get_visible_child_name () == "loading") {
                var child = this.stack.get_child_by_name ("loading");
                this.stack.remove (child);
            }

            this.stack.show_all ();
        });
    }
}
