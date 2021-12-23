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

public class Onboarding.PhilipsHueView : Onboarding.AbstractOnboardingView {
    public PhilipsHueView () {
        Object (
            description: _("Smart ZigBee lights by Philips Hue are supported. They must already be connected to your Philips Hue Bridge."),
            icon_name: "com.manexim.home.logo.philips.hue-symbolic",
            title: "Philips Hue"
        );
    }
}
