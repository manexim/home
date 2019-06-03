namespace Lifx {
    public class Service {
        public signal void onNewLamp (string name);

        public Service () {
            new Thread<void*> (null, () => {
                var i = 0;

                while (true) {
                    this.onNewLamp (i++.to_string ("%d"));

                    Thread.usleep (1000 * 1000);
                }
            });
        }
    }
}
