/* Copyright 2015 Sam Thomas
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

namespace Hourglass.Widgets {

    public enum CountDirection {
        UP,
        DOWN
    }

    public class Counter {

        public struct Time {
            int hours;
            int minutes;
            int seconds;
            int milliseconds;
        }

        private int current_time; //in milliseconds
        private Label time_label_w_milli; //with milliseconds
        private Label time_label_wo_milli; //without milliseconds
        private CountDirection direction;
        private uint time_step = 10;
        private uint timeout_id; //timeout_id

        //private string[] hours = {"", N_("hour"), N_("hours")};
        //private string[] mins = {"", N_("minute"), N_("minutes")};
        private bool should_stay_open;

        private bool should_notify;
        private string notify_summary;
        private string notify_body;

        public signal void on_tick (); //on tick signal
        public signal void on_start (); //when timer starts
        public signal void on_stop (); //when timer is stopped
        public signal void on_end (); //when timer finishes

        //constructor
        public Counter (CountDirection direction, bool should_stay_open = false) {
            time_label_w_milli = new Label ("");
            time_label_wo_milli = new Label ("");
            set_current_time (0);
            this.should_stay_open = should_stay_open;
            should_notify = false;
            this.direction = direction;
            update_label ();
        }

        public Counter.with_time (CountDirection direction, int milliseconds, bool should_stay_open = false) {
            time_label_w_milli = new Label ("");
            time_label_wo_milli = new Label ("");
            set_current_time (milliseconds);
            this.should_stay_open = should_stay_open;
            should_notify = false;
            this.direction = direction;
            update_label ();
        }

        public void start () {
            if (timeout_id == 0) {
                timeout_id = Timeout.add (time_step, tick);
            } if (should_stay_open) Hourglass.running = true;
            on_start ();
        }

        public void stop () {
            if (timeout_id != 0) {
                Source.remove (timeout_id);
                timeout_id = 0;
            } Hourglass.running = false;
            on_stop ();

            if (Hourglass.main_window == null) {
                Gtk.main_quit ();
            }
        }

        private bool tick () {
            //set inc based on direction
            var inc = 0;
            if (direction == CountDirection.UP) inc = 1;
            else if (direction == CountDirection.DOWN) inc = -1;

            //if current time is greater than 0, increment time counter
            if (current_time >= 0) {
                current_time += inc;
            } else {
                if (should_notify) {
                    Hourglass.dbus_server.show_notification (notify_summary, notify_body);
                }
                stop ();
                on_end ();
            }

            update_label ();
            on_tick (); //fire signal
            return true;
        }

        public void set_current_time (int time) {
            current_time = time;
            update_label ();
        }

        public int get_current_time () {
            return current_time;
        }

        public void set_should_notify (bool b = true, string? summary = null, string? body = null) {
            should_notify = b;
            notify_summary = summary;
            notify_body = body;
        }

        public Label get_label (bool milli = true) {
            if (milli) {
                return time_label_w_milli;
            } else {
                return time_label_wo_milli;
            }
        }

        public void update_label () {
            time_label_w_milli.set_label (get_time_string (true));
            time_label_wo_milli.set_label (get_time_string (false));
            time_label_w_milli.show ();
            time_label_wo_milli.show ();
        }

        public void set_label_class (string class) {
            time_label_w_milli.get_style_context ().add_class (class);
            time_label_wo_milli.get_style_context ().add_class (class);
        }

        public string get_time_string (bool with_milli = true) {
            return create_time_string (current_time, with_milli);
        }

        public static string create_time_string (int alt_time, bool with_milli = true) {
            Time t = parse_seconds (alt_time);
            if (with_milli) {
                if (t.hours == 0) {
                    return "%02d:%02d:%02d".printf (t.minutes, t.seconds, t.milliseconds);
                } return "%02d:%02d:%02d:%02d".printf (t.hours, t.minutes, t.seconds, t.milliseconds);
            } else {
                if (t.hours == 0) {
                    return "%02d:%02d".printf (t.minutes, t.seconds);
                } return "%02d:%02d:%02d".printf (t.hours, t.minutes, t.seconds);
            }
        }

        public static Time parse_seconds (int time) {
            Time t = Time ();
            t.hours = time / 360000;
            time %= 360000;
            t.minutes = time / 6000;
            time %= 6000;
            t.seconds = time / 100;
            t.milliseconds = time % 100;
            return t;
        }
    }
}
