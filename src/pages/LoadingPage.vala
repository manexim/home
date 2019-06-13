public class LoadingPage : Gtk.Grid {
    public LoadingPage () {
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;

        var label = new Gtk.Label ("Looking for smart home gadgets to control.");
		label.halign = Gtk.Align.CENTER;
		label.valign = Gtk.Align.CENTER;

        var spinner = new Gtk.Spinner ();
		spinner.halign = Gtk.Align.CENTER;
		spinner.valign = Gtk.Align.CENTER;
		spinner.start ();

        attach (label, 0, 0, 1, 1);
        attach (spinner, 0, 2, 1, 1);
    }
}
