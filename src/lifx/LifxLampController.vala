namespace Lifx {
    public class LifxLampController {
        private Lifx.Service service;
        private Lifx.LifxLamp _lamp;

        public signal void updated (Lifx.LifxLamp lamp);

        public LifxLampController (Lifx.LifxLamp lamp) {
            this._lamp = lamp;

            this.service = Lifx.Service.instance;
            this.service.onUpdatedThing.connect ((updatedLamp) => {
                if (updatedLamp.id == this.lamp.id) {
                    this.updated (updatedLamp as Lifx.LifxLamp);
                }
            });
        }

        public void switchPower (bool on) {
            this.service.setPower (this.lamp, on ? 65535 : 0);

            this._lamp.power = on ? Power.ON : Power.OFF;
        }

        public Lifx.LifxLamp lamp {
            get {
                return this._lamp;
            }
        }
    }
}
