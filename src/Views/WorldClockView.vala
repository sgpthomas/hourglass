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
        public GLib.TimeZone? tz { get; private set; }
        public string name { get; construct; }

        public Region (string id, string name) {
            Object (
                name: name
            );
            tz = get_tz_from_id (id);
        }

        private GLib.TimeZone? get_tz_from_id (string id) {
            GLib.TimeZone? tz = null;

            try {
                tz = new TimeZone.identifier (id);
            } catch (Error e) {
                warning (e.message);
            }

            return tz;
        }
    }

    private class ClockRow : Gtk.Grid {
        private Gtk.Label name_label;
        private Gtk.Label delta_label;
        private Gtk.Image time_icon;
        private Gtk.Label time_label;
        private Gtk.Box time_box;

        public ClockRow () {
        }

        construct {
            row_spacing = 6;
            margin_top = 12;
            margin_bottom = 12;
            margin_start = 18;
            margin_end = 18;

            name_label = new Gtk.Label (null);
            name_label.add_css_class (Granite.STYLE_CLASS_H2_LABEL);
            name_label.halign = Gtk.Align.START;

            delta_label = new Gtk.Label (null);
            delta_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
            delta_label.halign = Gtk.Align.START;

            time_icon = new Gtk.Image ();

            time_label = new Gtk.Label (null);

            time_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                halign = Gtk.Align.END,
                hexpand = true,
                valign = Gtk.Align.CENTER
            };
            time_box.append (time_icon);
            time_box.append (time_label);
            time_box.add_css_class ("time-box");

            attach (name_label, 0, 0, 1, 1);
            attach (delta_label, 0, 1, 1, 1);
            attach (time_box, 1, 0, 1, 2);
        }

        public void set_name_label (string name) {
            name_label.label = name;
        }

        public void set_time_box (GLib.TimeZone? tz) {
            GLib.DateTime time;

            if (tz == null) {
                return;
            }

            time = new DateTime.now (tz);
            var time_in_local = new DateTime.local (
                time.get_year (), time.get_month (), time.get_day_of_month (),
                time.get_hour (), time.get_minute (), time.get_seconds ()
            );

            time_label.label = time.format ("%H:%M");
            delta_label.label = get_delta (time_in_local);

            var hour = time.get_hour ();
            if (5 < hour && hour < 18) {
                time_label_daytime ();
            } else {
                time_label_night ();
            }
        }

        private void time_label_daytime () {
            time_icon.icon_name = "weather-clear";
            time_box.add_css_class ("time-daytime");
        }

        private void time_label_night () {
            time_icon.icon_name = "weather-clear-night";
            time_box.add_css_class ("time-night");
        }
    }

    construct {
        regions = new GLib.ListStore (typeof (Region));
        // TODO: Allow users to add/remove timezones
        regions.append (new Region ("Europe/London", _("London, UK")));
        regions.append (new Region ("America/Santiago", _("Santiago, US")));
        regions.append (new Region ("America/Anchorage", _("Anchorage, US")));
        regions.append (new Region ("Asia/Tokyo", _("Tokyo, Japan")));

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
        row.set_time_box (region.tz);
    }

    // Inspired from the implementation of Granite.DateTime.get_relative_datetime ()
    public static string get_delta (GLib.DateTime date_time) {
        var now = new GLib.DateTime.now_local ();
        var diff = now.difference (date_time);

        string day = "";
        if (Granite.DateTime.is_same_day (date_time, now)) {
            day = _("Today");
        } else if (Granite.DateTime.is_same_day (date_time.add_days (1), now)) {
            day = _("Yesterday");
        } else if (Granite.DateTime.is_same_day (date_time.add_days (-1), now)) {
            day = _("Tomorrow");
        }

        string hour;
        if (diff > 0) {
            if (diff < TimeSpan.HOUR) {
                return _("Current timezone");
            } else {
                int rounded = (int) Math.round ((double) diff / TimeSpan.HOUR);
                hour = dngettext (GETTEXT_PACKAGE, "%d hour behind", "%d hours behind", (ulong) rounded).printf (rounded);
            }
        } else {
            if (diff < TimeSpan.HOUR) {
                return _("Current timezone");
            } else {
                diff = -1 * diff;
                int rounded = (int) Math.round ((double) diff / TimeSpan.HOUR);
                hour = dngettext (GETTEXT_PACKAGE, "%d hour ahead", "%d hours ahead", (ulong) rounded).printf (rounded);
            }
        }

        return _("%s, %s".printf (day, hour));
    }
}
