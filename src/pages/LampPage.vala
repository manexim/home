public class LampPage : Granite.SimpleSettingsPage {
    private Lifx.LifxLampController controller;

    public LampPage (Lamp lamp) {
        Object (
            activatable: true,
            icon_name: "com.github.manexim.home.lightbulb.lifx",
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
