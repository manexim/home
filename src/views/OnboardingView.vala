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

public class Views.OnboardingView : Gtk.Grid {
    public signal void start ();

    public OnboardingView () {
        var stack = new Gtk.Stack ();
        stack.expand = true;
        stack.valign = stack.halign = Gtk.Align.CENTER;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        var start_view = new Onboarding.StartView ();
        stack.add_titled (start_view, "start", start_view.title);
        stack.child_set_property (start_view, "icon-name", "pager-checked-symbolic");

        var lifx_view = new Onboarding.LIFXView ();
        stack.add_titled (lifx_view, "lifx", lifx_view.title);
        stack.child_set_property (lifx_view, "icon-name", "pager-checked-symbolic");

        var philips_hue_view = new Onboarding.PhilipsHueView ();
        stack.add_titled (philips_hue_view, "philips_hue", philips_hue_view.title);
        stack.child_set_property (philips_hue_view, "icon-name", "pager-checked-symbolic");

        var finish_view = new Onboarding.FinishView ();
        stack.add_titled (finish_view, "finish", finish_view.title);
        stack.child_set_property (finish_view, "icon-name", "pager-checked-symbolic");

        GLib.List<unowned Gtk.Widget> views = stack.get_children ();
        foreach (Gtk.Widget view in views) {
            var view_name_value = GLib.Value (typeof (string));
            stack.child_get_property (view, "name", ref view_name_value);
        }

        var skip_button = new Gtk.Button.with_label (_("Skip All"));

        var skip_revealer = new Gtk.Revealer ();
        skip_revealer.reveal_child = true;
        skip_revealer.transition_type = Gtk.RevealerTransitionType.NONE;
        skip_revealer.add (skip_button);

        var stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.halign = Gtk.Align.CENTER;
        stack_switcher.stack = stack;

        var next_button = new Gtk.Button.with_label (_("Next"));
        next_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
        action_area.margin_start = action_area.margin_end = 10;
        action_area.expand = true;
        action_area.spacing = 6;
        action_area.valign = Gtk.Align.END;
        action_area.layout_style = Gtk.ButtonBoxStyle.EDGE;
        action_area.add (skip_revealer);
        action_area.add (stack_switcher);
        action_area.add (next_button);
        action_area.set_child_non_homogeneous (stack_switcher, true);

        margin_bottom = 10;
        orientation = Gtk.Orientation.VERTICAL;
        row_spacing = 24;
        add (stack);
        add (action_area);

        next_button.grab_focus ();

        stack.notify["visible-child-name"].connect (() => {
            if (stack.visible_child_name == "finish") {
                next_button.label = _("Get Started");
                skip_revealer.reveal_child = false;
            } else {
                next_button.label = _("Next");
                skip_revealer.reveal_child = true;
            }
        });

        next_button.clicked.connect (() => {
            GLib.List<unowned Gtk.Widget> current_views = stack.get_children ();
            var index = current_views.index (stack.visible_child);
            if (index < current_views.length () - 1) {
                stack.visible_child = current_views.nth_data (index + 1);
            } else {
                start ();
            }
        });

        skip_button.clicked.connect (() => {
            foreach (Gtk.Widget view in views) {
                var view_name_value = GLib.Value (typeof (string));
                stack.child_get_property (view, "name", ref view_name_value);
            }

            stack.visible_child_name = "finish";
        });
    }
}
