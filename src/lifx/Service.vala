namespace Lifx {
    public class Service {
        public signal void onNewThing (Thing thing);

        public Service () {
            new Thread<void*> (null, () => {
                var i = 0;

                while (true) {
                    var lamp = new Lamp ();
                    lamp.id = i.to_string ("0x%06X");
                    lamp.name = i++.to_string ("Lamp %d");
                    this.onNewThing (lamp);

                    Thread.usleep (1000 * 1000);
                }
            });
        }
    }
}
