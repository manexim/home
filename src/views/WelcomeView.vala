public class WelcomeView : Gtk.Grid {
    public signal void start ();

    construct {
        var welcome = new Granite.Widgets.Welcome ("Home", "Control your smart home gadgets");
        welcome.append ("com.github.manexim.home.lightbulb.lifx-symbolic", "LIFX", "Currently only LIFX lights are supported. They must already be connected to your Wi-Fi.");
        welcome.append ("go-next", "Let's go", "You can control your lamps directly via Wi-Fi.");

        welcome.set_item_sensitivity (0, false);

        add (welcome);

        welcome.activated.connect ((index) => {
            switch (index) {
            case 1:
                start ();
                break;
            }
        });
    }
}
