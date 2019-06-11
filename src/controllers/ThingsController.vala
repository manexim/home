public class ThingsController {
    private Lifx.Service lifxService;

    public signal void onNewLamp(Lamp lamp);
    public signal void onUpdatedLamp(Lamp lamp);

    public ThingsController () {
        this.lifxService = Lifx.Service.instance;

        this.lifxService.onNewThing.connect ((thing) => {
            this.onNewLamp(thing as Lamp);
        });

        this.lifxService.onUpdatedThing.connect ((thing) => {
            this.onUpdatedLamp(thing as Lamp);
        });
    }
}
