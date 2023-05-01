/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Ryo Nakano
 */

public class Hourglass.Views.WorldClockView : AbstractView {
    public override string id {
        get {
            return "world-clock";
        }
    }

    public override string display_name {
        get {
            return _("World Clock");
        }
    }

    public override bool should_keep_open {
        get {
            return false;
        }
    }

    private GLib.ListStore regions;

    private class Region : GLib.Object {
        public string id { get; construct; }
        public string name { get; construct; }

        public Region (string id, string name) {
            Object (
                id: id,
                name: name
            );
        }
    }

    private class ClockRow : Gtk.Grid {
        private Gtk.Label name_label;
        private Gtk.Label time_label;

        public ClockRow () {
        }

        construct {
            row_spacing = 6;
            margin_top = 6;
            margin_bottom = 6;

            name_label = new Gtk.Label (null) {
                valign = Gtk.Align.END
            };
            name_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

            time_label = new Gtk.Label (null) {
                halign = Gtk.Align.END,
                hexpand = true
            };
            time_label.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

            attach (name_label, 0, 0, 1, 1);
            attach (time_label, 1, 0, 1, 1);
        }

        public void set_name_label (string name) {
            name_label.label = name;
        }

        public void set_time_label (string id) {
            GLib.TimeZone tz;
            GLib.DateTime time;

            try {
                tz = new TimeZone.identifier (id);
                time = new DateTime.now (tz);
                time_label.label = time.format ("%H:%M");
            } catch (Error e) {
                warning (e.message);
            }
        }
    }

    construct {
        regions = new GLib.ListStore (typeof (Region));
        // TODO: Allow users to add/remove timezones
        regions.append (new Region ("Europe/London", _("London")));
        regions.append (new Region ("Asia/Tokyo", _("Tokyo")));

        var selection = new Gtk.SingleSelection (regions);
        var factory = new Gtk.SignalListItemFactory ();

        var list_view = new Gtk.ListView (selection, factory);

        factory.setup.connect (setup_cb);
        factory.bind.connect (bind_cb);

        append (list_view);
        add_css_class (Granite.STYLE_CLASS_FRAME);
    }

    private void setup_cb (Object object) {
        var item = object as Gtk.ListItem;

        var row = new ClockRow ();
        item.child = row;
    }

    private void bind_cb (Object object) {
        var item = object as Gtk.ListItem;
        var region = item.item as Region;
        var row = item.child as ClockRow;

        row.set_name_label (region.name);
        row.set_time_label (region.id);
    }
}
