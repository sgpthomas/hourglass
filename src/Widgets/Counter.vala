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

		private DateTime start_time;
        private int current_time; // in milliseconds
		private int limit;
		private int last_time = 0; // in milliseconds
        private Label time_label_w_milli; // with milliseconds
        private Label time_label_wo_milli; // without milliseconds
        private CountDirection direction;
        private uint time_step = 10;
        private uint timeout_id; // timeout_id

        private bool should_notify;
        private string notify_summary;
        private string notify_body;

        public signal void on_tick (); // on tick signal
        public signal void on_start (); // when timer starts
        public signal void on_stop (); // when timer is stopped
        public signal void on_end (); // when timer finishes

        // constructor
        public Counter (CountDirection direction) {
            time_label_w_milli = new Label ("");
            time_label_wo_milli = new Label ("");
            set_current_time (0);
            should_notify = false;
            this.direction = direction;
            update_label ();
        }

        public Counter.with_time (CountDirection direction, int milliseconds, bool should_stay_open = false) {
            time_label_w_milli = new Label ("");
            time_label_wo_milli = new Label ("");
            set_current_time (milliseconds);
            should_notify = false;
            this.direction = direction;
            update_label ();
        }

        public void start () {
			start_time = new DateTime.now_local ();

            if (timeout_id == 0) {
                timeout_id = Timeout.add (time_step, tick);
            }

            on_start ();
        }

        public void stop () {
			last_time = current_time;
            if (timeout_id != 0) {
                Source.remove (timeout_id);
                timeout_id = 0;
            }

            on_stop ();

            if (!Hourglass.window_open) {
                Hourglass.saved.set_boolean ("timer-state", false); // prevents timer from going off again when you start up the app
                Gtk.main_quit ();
            }
        }

        private bool tick () {
			var diff = (new DateTime.now_local ()).difference(start_time);

			if (direction == CountDirection.UP) {
				current_time = (int)diff + last_time;
			} else {
				if (current_time >= 0) {
					current_time = limit - (int)diff;
				} else {
					if (should_notify) {
						Hourglass.dbus_server.show_notification (notify_summary, notify_body);
					}
					stop ();
					on_end ();
				}
			}

            update_label ();
            on_tick (); // fire signal
            return true;
        }

        public void set_current_time (int time) {
            current_time = time;
			last_time = 0;
            update_label ();
        }

        public int get_current_time () {
            return current_time;
        }

		public void set_limit (int time) {
			limit = time;
			current_time = time;
		}

		public bool get_active () {
			return this.current_time > 0;
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
			t.hours = time / (int) TimeSpan.HOUR;
			time %= (int) TimeSpan.HOUR;
			t.minutes = time / (int) TimeSpan.MINUTE;
			time %= (int) TimeSpan.MINUTE;
			t.seconds = time / (int) TimeSpan.SECOND;
			time %= (int) TimeSpan.SECOND;
			t.milliseconds = time % ((int) TimeSpan.MILLISECOND / 10);
			return t;
        }
    }
}
