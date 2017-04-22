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

using Gtk;
using Granite.DateTime;

namespace Hourglass.Widgets {

    public enum Days {
        SUNDAY,
        MONDAY,
        TUESDAY,
        WEDNESDAY,
        THURSDAY,
        FRIDAY,
        SATURDAY
    }

    public class Alarm : Gtk.ListBoxRow {

        public DateTime time;
        public string title;
        public int[] repeat;

        // widgets
        private Switch toggle;

        // signals
        public signal void state_toggled (bool state);

        public Alarm (DateTime time, string title, int[]? repeat = null) {
            this.time = time;
            this.title = title;
            this.repeat = repeat;

            create_layout ();
        }

        private void create_layout () {
            var grid = new Grid ();
            grid.margin_start = 6;
            grid.margin_end = 6;

            var str = get_time_string ();

            var time = new Label (str);
            time.get_style_context ().add_class ("alarm-time");

            var name = new Label (title);
            name.get_style_context ().add_class ("alarm-name");

            var days = new Label (make_repeat_label ());
            days.get_style_context ().add_class ("alarm-days");

            toggle = new Switch ();
            toggle.set_halign (Gtk.Align.END);
            toggle.set_valign (Gtk.Align.CENTER);
            toggle.notify["active"].connect (() => {
                state_toggled (toggle.active);
            });

            grid.attach (time, 0, 0, 1, 1);
            grid.attach (name, 0, 1, 1, 1);
            grid.attach (days, 1, 0, 1, 2);
            grid.attach (new Spacer.w_hexpand (), 2, 0, 1, 2);
            grid.attach (toggle, 3, 0, 1, 2);

            //this.add (box);
            this.add (grid);

            toggle.active = true;
        }

        public void set_toggle (bool b) {
            toggle.active = b;
        }

        public bool is_now () {
            var now = new DateTime.now_local ();
            bool same_day = time.get_day_of_month () == now.get_day_of_month ();
            bool same_month = time.get_month () == now.get_month ();
            bool same_hour = time.get_hour () == now.get_hour ();
            bool same_min = time.get_minute () == now.get_minute ();
            if (same_day && same_month && same_hour && same_min) {
                return true;
            } return false;
        }

        public string get_time_string () {
            var str = "";
            if (Hourglass.system_time_format.clock_format == "12h") {
                if (time.get_hour () < 13) {
                    if (time.get_minute () < 10) str = "%i:0%i am".printf (time.get_hour (), time.get_minute ());
                    else str = "%i:%i am".printf (time.get_hour (), time.get_minute ());
                } else {
                    if (time.get_minute () < 10) str = "%i:0%i pm".printf (time.get_hour () - 12, time.get_minute ());
                    else str = "%i:%i pm".printf (time.get_hour () - 12, time.get_minute ());
                }
            } else {
                if (time.get_minute () < 10) str = "%i:0%i".printf (time.get_hour (), time.get_minute ());
                else str = "%i:%i".printf (time.get_hour (), time.get_minute ());
            } return str;
        }

        private string make_repeat_label () {
            var str = "";

            var comp = new DateTime.now_local ();
            if (time.get_day_of_month () != comp.get_day_of_month () || time.get_month () != comp.get_month ()) {
                str += "%i/%i ".printf (time.get_month (), time.get_day_of_month ());
            }

            if (repeat.length > 0) {
                str += str == "" ? _("Repeats ") : _(", Repeats ");
                str += Dialogs.MultiSelectPopover.selected_to_string (repeat);
            }

            return str;
        }

        public string to_string () {
            var str = "";

            //add title
            str += title;
            str += ";";

            //add hours
            str += time.get_hour ().to_string ();
            str += ",";

            //add minutes
            str += time.get_minute ().to_string ();
            str += ";";

            //add date
            str += time.get_month ().to_string ();
            str += "-";

            str += time.get_day_of_month ().to_string ();
            str += ";";

            //add repeat days
            bool has_repeat_days = false;
            foreach (int i in repeat) {
                str += i.to_string ();
                str += ",";
                has_repeat_days = true;
            }
            if (has_repeat_days) str = str.slice (0, str.length - 1);
            else str += "none";
            str += ";";

            //add state
            if (toggle.active) {
                str += "on;";
            } else {
                str += "off;";
            }

            return str;
        }

        public static Alarm parse_string (string alarm_string) {
            //Alarm a = new Alarm (new DateTime.now_local (), "TestAlarm");
            string[] parts = alarm_string.split (";");

            //title
            var title = parts[0];

            //time
            var time_string_parts = parts[1].split (",");
            var hour = int.parse (time_string_parts[0]);
            var min = int.parse (time_string_parts[1]);

            //day and month
            var date_string_parts = parts[2].split ("-");
            var month = int.parse (date_string_parts[0]);
            var day = int.parse (date_string_parts[1]);

            var time = new DateTime.local (new DateTime.now_local ().get_year (), month, day, hour, min, 0);

            //repeat
            int[] repeat_days = {};
            var repeat_string_parts = parts[3].split (",");
            foreach (string str in repeat_string_parts) {
                if (str == "none") { //if day is none, set repeat days to null and break
                    repeat_days = null;
                    break;
                } int i = int.parse (str);
                repeat_days += i;
            }

            var a = new Alarm (time, title, repeat_days);

            //state
            if (parts[4] == "on") {
                a.set_toggle (true);
            } else {
                a.set_toggle (false);
            }

            return a;

        }

        public static bool is_valid_alarm_string (string alarm_string) {
            if (";" in alarm_string) {
                string[] parts = alarm_string.split (";");
                if (parts.length != 6) return false; //if wrong number of sections return false

                //check if time section is correct
                var time_string_parts = parts[1].split (",");
                foreach (string s in time_string_parts) {
                    int64 i = 0;
                    if (!int64.try_parse (s, out i)) {
                        return false;
                    }
                }

                //check if date section is correct
                var date_string_parts = parts[2].split ("-");
                foreach (string s in date_string_parts) {
                    int64 i = 0;
                    if (!int64.try_parse (s, out i)) {
                        return false;
                    }
                }

                //check if repeat days is correct
                if (parts[3] != "none") {
                    var repeat_string_parts = parts[3].split (",");
                    foreach (string s in repeat_string_parts) {
                        int64 i = 0;
                        if (!int64.try_parse (s, out i)) {
                            return false;
                        }
                    }
                }

                //check state
                if (!(parts[4] in "on off")) {
                    return false;
                }

                return true;
            } else {
                return false;
            }
        }

    }
}
