namespace Lifx {
    public class LifxLampController {
        private Lifx.Service service;
        private Lifx.LifxLamp lamp;

        public signal void updated (Lifx.LifxLamp lamp);

        public LifxLampController (Lifx.LifxLamp lamp) {
            this.lamp = lamp;

            this.service = Lifx.Service.instance;
            this.service.onUpdatedThing.connect ((updatedLamp) => {
                if (updatedLamp.id == this.lamp.id) {
                    this.updated (updatedLamp as Lifx.LifxLamp);
                }
            });
        }
    }
}
