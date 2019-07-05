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

public abstract class Pages.AbstractDevicePage : Granite.SettingsPage {
    private Gtk.Button header_icon_button;
    private Gtk.Label description_label;
    private Gtk.Label title_label;
    private string _description;

    public Gtk.ButtonBox action_area { get; construct; }
    public Gtk.Grid content_area { get; construct; }
    public Gtk.Switch? status_switch { get; construct; }
    public bool activatable { get; construct; }

    public string description {
        get {
            return _description;
        }
        construct set {
            if (description_label != null) {
                description_label.label = value;
            }
            _description = value;
        }
    }

    public new string icon_name {
        get {
            return _icon_name;
        }
        construct set {
            if (header_icon_button != null) {
                header_icon_button.set_image (new Gtk.Image.from_icon_name (value, Gtk.IconSize.LARGE_TOOLBAR));
            }
            _icon_name = value;
        }
    }

    public new string title {
        get {
            return _title;
        }
        construct set {
            if (title_label != null) {
                title_label.label = value;
            }
            _title = value;
        }
    }

    protected AbstractDevicePage () {}

    construct {
        header_icon_button = new Gtk.Button.from_icon_name (icon_name, Gtk.IconSize.DIALOG);
        header_icon_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        header_icon_button.valign = Gtk.Align.START;

        header_icon_button.clicked.connect (() => {
            var icon_popover = new Widgets.IconPopover (header_icon_button);
            icon_popover.change_icon.connect ((name) => {
                icon_name = name;
            });
            icon_popover.show_all ();
        });

        title_label = new Gtk.Label (title);
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.xalign = 0;
        title_label.get_style_context ().add_class ("h2");

        var header_area = new Gtk.Grid ();
        header_area.column_spacing = 12;
        header_area.row_spacing = 3;

        header_area.attach (title_label, 1, 0);

        if (description != null) {
            description_label = new Gtk.Label (description);
            description_label.xalign = 0;
            description_label.wrap = true;

            header_area.attach (header_icon_button, 0, 0, 1, 2);
            header_area.attach (description_label, 1, 1);
        } else {
            header_area.attach (header_icon_button, 0, 0);
        }

        if (activatable) {
            status_switch = new Gtk.Switch ();
            status_switch.hexpand = true;
            status_switch.halign = Gtk.Align.END;
            status_switch.valign = Gtk.Align.CENTER;
            header_area.attach (status_switch, 2, 0);
        }

        content_area = new Gtk.Grid ();
        content_area.column_spacing = 12;
        content_area.row_spacing = 12;
        content_area.vexpand = true;

        action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
        action_area.set_layout (Gtk.ButtonBoxStyle.END);
        action_area.spacing = 6;

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.row_spacing = 24;
        grid.add (header_area);
        grid.add (content_area);
        grid.add (action_area);

        add (grid);

        set_action_area_visibility ();

        action_area.add.connect (set_action_area_visibility);
        action_area.remove.connect (set_action_area_visibility);

        notify["icon-name"].connect (() => {
            if (header_icon_button != null) {
                header_icon_button.set_image (new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.LARGE_TOOLBAR));
            }
        });

        notify["title"].connect (() => {
            if (title_label != null) {
                title_label.label = title;
            }
        });
    }

    private void set_action_area_visibility () {
        if (action_area.get_children () != null) {
            action_area.no_show_all = false;
            action_area.show ();
        } else {
            action_area.no_show_all = true;
            action_area.hide ();
        }
    }
}
