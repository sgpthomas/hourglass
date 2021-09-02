/* Copyright 2015-2017 Sam Thomas
*
* This file is part of Hourglass.
*
* Hourglass is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Hourglass is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Hourglass. If not, see http://www.gnu.org/licenses/.
*/

public class Hourglass.Widgets.Alarm : Gtk.ListBoxRow {
    public signal void state_toggled ();

    public GLib.DateTime time { get; construct; }
    public bool has_date { get; construct; }
    public string title { get; construct; }
    public int[] repeat;

    private Gtk.Switch toggle;

    public Alarm (GLib.DateTime time, bool has_date, string title, int[]? repeat = null) {
        Object (
            time: time,
            has_date: has_date,
            title: title
        );
        this.repeat = repeat;

        var time_label = new Gtk.Label (get_time_string ());
        time_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var name_label = new Gtk.Label (title);
        name_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var days_label = new Gtk.Label (make_repeat_label ());

        var grid = new Gtk.Grid () {
            row_spacing = 6,
            column_spacing = 12
        };
        grid.attach (time_label, 0, 0, 1, 1);
        grid.attach (name_label, 0, 1, 1, 1);
        grid.attach (days_label, 1, 0, 1, 2);

        toggle = new Gtk.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            active = true
        };
        toggle.notify["active"].connect (() => {
            state_toggled ();
        });

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12
        };
        box.pack_start (grid);
        box.pack_end (toggle);

        add (box);
    }

    public void set_toggle (bool b) {
        toggle.active = b;
    }

    private string get_time_string () {
        var system_time_format = new GLib.Settings ("org.gnome.desktop.interface");

        var time_format = Granite.DateTime.get_default_time_format (
            system_time_format.get_enum ("clock-format") == 1, false
        );

        return time.format (time_format);
    }

    private string make_repeat_label () {
        var str = "";

        var comp = new GLib.DateTime.now_local ();
        if (!Granite.DateTime.is_same_day (time, comp)) {
            str += Granite.DateTime.get_relative_datetime (time);
        }

        if (repeat.length > 0) {
            if (str == "") {
                str += _("Repeats: %s").printf (Dialogs.MultiSelectPopover.selected_to_string (repeat));
            } else {
                str += _(", Repeats: %s").printf (Dialogs.MultiSelectPopover.selected_to_string (repeat));
            }
        }

        return str;
    }

    public string to_string () {
        var str = "";

        //add title
        str += title;
        str += Utils.ALARM_INFO_SEPARATOR;

        //add hours
        str += time.get_hour ().to_string ();
        str += ",";

        //add minutes
        str += time.get_minute ().to_string ();
        str += Utils.ALARM_INFO_SEPARATOR;

        //add date
        if (has_date) {
            str += time.get_month ().to_string ();
            str += "-";
            str += time.get_day_of_month ().to_string ();
            str += "-";
            str += time.get_year ().to_string ();
        } else {
            str += "none";
        }

        str += Utils.ALARM_INFO_SEPARATOR;

        //add repeat days
        bool has_repeat_days = false;
        foreach (int i in repeat) {
            str += i.to_string ();
            str += ",";
            has_repeat_days = true;
        }

        if (has_repeat_days) {
            str = str.slice (0, str.length - 1);
        } else {
            str += "none";
        }

        str += Utils.ALARM_INFO_SEPARATOR;

        //add state
        if (toggle.active) {
            str += "on;";
        } else {
            str += "off;";
        }

        return str;
    }

    public static Alarm parse_string (string alarm_string) {
        string[] parts = alarm_string.split (Hourglass.Utils.ALARM_INFO_SEPARATOR);

        //title
        var title = parts[0];

        //time
        var time_string_parts = parts[1].split (",");
        var hour = int.parse (time_string_parts[0]);
        var min = int.parse (time_string_parts[1]);

        //day and month
        var now = new GLib.DateTime.now_local ();

        int month, day, year;
        bool has_date = false;
        if (parts[2] == "none") {
            month = now.get_month ();
            day = now.get_day_of_month ();
            year = now.get_year ();
        } else {
            has_date = true;
            var date_string_parts = parts[2].split ("-");
            month = int.parse (date_string_parts[0]);
            day = int.parse (date_string_parts[1]);
            year = int.parse (date_string_parts[2]);
        }

        var time = new GLib.DateTime.local (year, month, day, hour, min, 0);

        //repeat
        int[] repeat_days = {};
        var repeat_string_parts = parts[3].split (",");
        foreach (string str in repeat_string_parts) {
            if (str == "none") { //if day is none, set repeat days to null and break
                repeat_days = null;
                break;
            }

            int i = int.parse (str);
            repeat_days += i;
        }

        var a = new Alarm (time, has_date, title, repeat_days);

        //state
        if (parts[4] == "on") {
            a.set_toggle (true);
        } else {
            a.set_toggle (false);
        }

        return a;
    }
}
