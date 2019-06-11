public class LampPage : Granite.SimpleSettingsPage {
    private Lifx.LifxLampController controller;
    private Gtk.Entry hue_entry;
    private Gtk.Entry saturation_entry;
    private Gtk.Entry brightness_entry;
    private Gtk.Entry kelvin_entry;

    public LampPage (Lamp lamp) {
        Object (
            activatable: true,
            icon_name: "dialog-question",
            description: lamp.id,
            title: lamp.name != null ? lamp.name : lamp.id
        );

        this.controller = new Lifx.LifxLampController (lamp as Lifx.LifxLamp);
        this.controller.updated.connect ((lamp) => {
            if (lamp.power == Power.ON) {
                this.status_switch.active = true;
                this.status_switch.state = true;
            } else if (lamp.power == Power.OFF) {
                this.status_switch.active = false;
                this.status_switch.state = false;
            }

            this.title = lamp.name;
            this.hue_entry.text = lamp.hue.to_string ();
            this.saturation_entry.text = lamp.saturation.to_string ();
            this.brightness_entry.text = lamp.brightness.to_string ();
            this.kelvin_entry.text = lamp.kelvin.to_string ();

            updateStatus ();
        });

        updateStatus ();

        status_switch.notify["active"].connect (updateStatus);

        status_switch.state_set.connect ((state) => {
            this.controller.switchPower (state);

            this.status_switch.active = state;
            this.status_switch.state = state;

            return state;
        });
    }

    construct {
        var hue_label = new Gtk.Label ("Hue:");
        hue_label.xalign = 1;

        hue_entry = new Gtk.Entry ();
        hue_entry.hexpand = true;
        hue_entry.placeholder_text = "This lamp's hue";

        var saturation_label = new Gtk.Label ("Saturation:");
        saturation_label.xalign = 1;

        saturation_entry = new Gtk.Entry ();
        saturation_entry.hexpand = true;
        saturation_entry.placeholder_text = "This lamp's saturation";

        var brightness_label = new Gtk.Label ("Brightness:");
        brightness_label.xalign = 1;

        brightness_entry = new Gtk.Entry ();
        brightness_entry.hexpand = true;
        brightness_entry.placeholder_text = "This lamp's brightness";

        var kelvin_label = new Gtk.Label ("Kelvin:");
        kelvin_label.xalign = 1;

        kelvin_entry = new Gtk.Entry ();
        kelvin_entry.hexpand = true;
        kelvin_entry.placeholder_text = "This lamp's kelvin";

        content_area.attach (hue_label, 0, 0, 1, 1);
        content_area.attach (hue_entry, 1, 0, 1, 1);
        content_area.attach (saturation_label, 0, 1, 1, 1);
        content_area.attach (saturation_entry, 1, 1, 1, 1);
        content_area.attach (brightness_label, 0, 2, 1, 1);
        content_area.attach (brightness_entry, 1, 2, 1, 1);
        content_area.attach (kelvin_label, 0, 3, 1, 1);
        content_area.attach (kelvin_entry, 1, 3, 1, 1);
    }

    private void updateStatus () {
        switch (this.controller.lamp.power) {
        case Power.ON:
            status_type = Granite.SettingsPage.StatusType.SUCCESS;
            status = ("Enabled");
            break;
        case Power.OFF:
            status_type = Granite.SettingsPage.StatusType.OFFLINE;
            status = ("Disabled");
            break;
        default:
            status_type = Granite.SettingsPage.StatusType.NONE;
            status = ("Unknown");
            break;
        }
    }
}
