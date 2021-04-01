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

public class Application : Granite.Application {
    private MainWindow window;

    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        // Register Middlewares
        Flux.Dispatcher.get_instance ().register_middleware (new LoggingMiddleware ());

        // Register Stores
        Flux.Dispatcher.get_instance ().register_store (new Store ());

        window = new MainWindow (this);

        window.show_all ();

        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("com/github/manexim/home/styles/application.css");
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }

    public static int main (string[] args) {
        var app = new Application ();

        return app.run (args);
    }
}
