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

public class Views.WelcomeView : Gtk.Grid {
    public signal void start ();

    construct {
        var welcome = new Granite.Widgets.Welcome ("Home", _("Control your smart home gadgets"));
        welcome.append (
            "com.github.manexim.home.logo.lifx-symbolic",
            "LIFX",
            _("Smart Wi-Fi lights by LIFX are supported. They must already be connected to your Wi-Fi.")
        );
        welcome.append (
            "com.github.manexim.home.logo.philips.hue-symbolic",
            "Philips Hue",
            _("Smart ZigBee lights by Philips Hue are supported. They must already be connected to your Philips Hue Bridge.")
        );
        welcome.append (
            "go-next",
            _("Let's go"),
            _("You can control your smart home gadgets directly via your local network. A connection to the internet is not required.")
        );

        welcome.set_item_sensitivity (0, false);
        welcome.set_item_sensitivity (1, false);

        add (welcome);

        welcome.activated.connect ((index) => {
            switch (index) {
            case 2:
                start ();
                break;
            }
        });
    }
}
