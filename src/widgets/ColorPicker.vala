public class Widgets.ColorPicker: Gtk.DrawingArea {
    private Gdk.RGBA color;
    private Gtk.Window window;
    private bool dialog_visible;

    public signal void on_color_change (Colors.RGB color);

    public ColorPicker (Gtk.Window window) {
        this.window = window;
        color.parse ("#4caf50");

        set_size_request (140, 140);
        add_events (Gdk.EventMask.ALL_EVENTS_MASK);

        button_press_event.connect ((event) => {
            if (event.button == 1 && !dialog_visible) {
                var dialog = new Gtk.ColorSelectionDialog ("");
                unowned Gtk.ColorSelection widget = dialog.get_color_selection ();

                widget.current_rgba = color;

                dialog.deletable = false;
                dialog.transient_for = window;
                dialog_visible = true;

                if (dialog.run () == Gtk.ResponseType.OK) {
                    if (color != widget.current_rgba) {
                        color = widget.current_rgba;

                        var rgb = new Colors.RGB ();
                        rgb.red = (uint8) (color.red * 255 + 0.5);
                        rgb.green = (uint8) (color.green * 255 + 0.5);
                        rgb.blue = (uint8) (color.blue * 255 + 0.5);

                        on_color_change (rgb);
                    }
                }

                dialog_visible = false;
                dialog.close ();
            }

            return true;
        });
    }

    public override bool draw (Cairo.Context ctx) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        // Draw an arc:
        double xc = width / 2.0;
        double yc = height / 2.0;
        double radius = (int.min (width, height) / 2.0);
        double angle1 = 0;
        double angle2 = 2 * Math.PI;

        int shadow_width = 6;
        double shadow_alpha = 1.0;
        string shadow_color = "#A9A9A9";
        for (int i = 1; i <= shadow_width; i++) {
            ctx.arc (xc, yc, radius - i, angle1, angle2);
            Gdk.RGBA c = Gdk.RGBA ();
            c.parse (shadow_color);
            c.alpha = shadow_alpha / ((shadow_width - i + 1) * (shadow_width - i + 1));
            Gdk.cairo_set_source_rgba (ctx, c);
            ctx.stroke ();
        }

        ctx.arc (xc, yc, radius - shadow_width, angle1, angle2);
        Gdk.cairo_set_source_rgba (ctx, color);
        ctx.fill ();

        return true;
    }

    public Colors.RGB rgb {
        set {
            color.parse (value.to_hex ());
        }
    }

    public Colors.HSB hsb {
        set {
            color.parse (new Colors.RGB.from_hsb (value).to_hex ());
        }
    }
}
