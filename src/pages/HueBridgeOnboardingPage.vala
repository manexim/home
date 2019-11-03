/*
* Copyright (c) 2019 Manexim (https://github.com/manexim)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class Pages.HueBridgeOnboardingPage : Gtk.Grid {
    private Philips.Hue.BridgeController controller;
    private Gtk.Label label;
    private Gtk.Spinner spinner;

    public HueBridgeOnboardingPage (Philips.Hue.Bridge bridge) {
        controller = new Philips.Hue.BridgeController (bridge);

        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        row_spacing = 16;

        var icon = new Gtk.Image ();
        icon.gicon = new ThemedIcon ("com.github.manexim.home.bridge.philips.hue-symbolic");
        icon.pixel_size = 256;

        label = new Gtk.Label (_("Press the push-link button in the middle of the Hue bridge."));

        spinner = new Gtk.Spinner ();
        spinner.start ();

        attach (icon, 0, 0, 1, 1);
        attach (label, 0, 1, 1, 1);
        attach (spinner, 0, 2, 1, 1);

        show_all ();

        register ();
    }

    private void register () {
        new Thread<void*> (null, () => {
            const ulong SLEEP_SECONDS = 5;

            while (true) {
                try {
                    if (controller.register ()) {
                        label.label = _("The Hue bridge was successfully registered.");
                        spinner.stop ();

                        Thread.usleep (SLEEP_SECONDS * 1000 * 1000);
                        MainWindow.get_default ().go_back ();
                    }
                } catch (GLib.Error e) {
                    stderr.printf ("Error: %d %s\n", e.code, e.message);
                }

                Thread.usleep (SLEEP_SECONDS * 1000 * 1000);
            }
        });
    }
}
