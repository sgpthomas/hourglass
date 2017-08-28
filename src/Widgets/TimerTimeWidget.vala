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

using Hourglass.Window;
using Hourglass.Widgets;

namespace Hourglass.Widgets {

    public class TimerTimeWidget : Gtk.Box, TimeWidget {

        // counter
        private Counter counter;

        // containers
        private Grid chooser_grid;
        private Grid timer_grid;
        private Stack stack;

        // elements
        private TimeSpinner hour_chooser;
        private TimeSpinner min_chooser;
        private TimeSpinner sec_chooser;
        private Button start_timer_button;
        private Button stop_timer_button;

        // timer value
        private int timer_value;

        // constructor
        public TimerTimeWidget (MainWindow window) {
            Object (orientation: Orientation.VERTICAL, spacing: 0);

            create_layout ();

            // connect some signals
            connect_signals ();

            // update display
            update ();

            // resume state
            if (Hourglass.saved.timer_state) {
                start_timer ();
            }

            // var str = Hourglass.saved.timer_state ? "timer_grid" : "chooser_grid";
            // stack.set_visible_child_name (str);
        }

        private void create_layout () {
            // configure counter
            counter = new Counter (CountDirection.DOWN);
            counter.set_label_class ("timer");

            // create stack
            stack = new Stack ();

            // chooser grid
            chooser_grid = new Grid ();
            chooser_grid.column_spacing = 6;
            chooser_grid.row_spacing = 12;

            // get current time from dconf
            Counter.Time t = Counter.parse_seconds (Hourglass.saved.timer_time * 100);

            hour_chooser = new TimeSpinner (59);
            hour_chooser.set_value (t.hours);
            hour_chooser.set_tooltip_text (_("Hours"));

            min_chooser = new TimeSpinner (59);
            min_chooser.set_value (t.minutes);
            min_chooser.set_tooltip_text (_("Minutes"));

            sec_chooser = new TimeSpinner (59);
            sec_chooser.set_value (t.seconds);
            sec_chooser.set_tooltip_text (_("Seconds"));

            start_timer_button = new Button.with_label (_("Start"));
            start_timer_button.get_style_context ().add_class ("round-button");
            start_timer_button.get_style_context ().add_class ("green-button");

            chooser_grid.attach (new Spacer.w_hexpand (), 0, 0, 1, 1);
            chooser_grid.attach (hour_chooser, 1, 0, 1, 1);

            chooser_grid.attach (new Label (_(":")), 2, 0, 1, 1);
            chooser_grid.attach (min_chooser, 3, 0, 1, 1);

            chooser_grid.attach (new Label (_(":")), 4, 0, 1, 1);
            chooser_grid.attach (sec_chooser, 5, 0, 1, 1);

            chooser_grid.attach (new Spacer.w_hexpand (), 6, 0, 1, 1);
            chooser_grid.attach (start_timer_button, 1, 1, 5, 1);

            // timer grid
            timer_grid = new Grid ();
            timer_grid.column_spacing = 6;
            timer_grid.row_spacing = 36;

            stop_timer_button = new Button.with_label (_("Stop"));
            stop_timer_button.get_style_context ().add_class ("round-button");
            stop_timer_button.get_style_context ().add_class ("red-button");

            timer_grid.attach (new Spacer.w_hexpand (), 0, 0, 1, 1);
            timer_grid.attach (counter.get_label (false), 1, 0, 1, 1);
            timer_grid.attach (new Spacer.w_hexpand (), 2, 0, 1, 1);
            timer_grid.attach (stop_timer_button, 1, 1, 1, 1);

            // add grids to the stack
            stack.add_titled (chooser_grid, "chooser_grid", "Chooser Grid");
            stack.add_titled (timer_grid, "timer_grid", "Timer Grid");

            this.pack_start (new Spacer ());
            this.pack_start (stack);
            this.pack_start (new Spacer ());
        }

        private void update () {
            // set sensitivity of the start button
            start_timer_button.sensitive = !(sec_chooser.get_value () == 0 && min_chooser.get_value () == 0 && hour_chooser.get_value () == 0);
        }

        private void connect_signals () {
            sec_chooser.value_changed.connect (() => {
                Hourglass.saved.timer_time = (int) ((hour_chooser.get_value () * 3600) + (min_chooser.get_value () * 60) + sec_chooser.get_value ());
                update ();
            });

            min_chooser.value_changed.connect (() => {
                Hourglass.saved.timer_time = (int) ((hour_chooser.get_value () * 3600) + (min_chooser.get_value () * 60) + sec_chooser.get_value ());
                update ();
            });

            hour_chooser.value_changed.connect (() => {
                Hourglass.saved.timer_time = (int) ((hour_chooser.get_value () * 3600) + (min_chooser.get_value () * 60) + sec_chooser.get_value ());
                update ();
            });

            start_timer_button.clicked.connect (start_timer);

            stop_timer_button.clicked.connect (stop_timer);

            counter.on_end.connect (stop_timer);
        }

        private void start_timer () {
            stack.set_visible_child_name ("timer_grid");

            var val = (int) (sec_chooser.get_value () + (min_chooser.get_value () * 60) + (hour_chooser.get_value () * 3600)) * 1000000;
            counter.set_limit (val);
            timer_value = val;

            counter.start ();

            // update saved time
            counter.on_tick.connect (() => {
                Hourglass.saved.timer_time = counter.get_current_time () / 1000;
                update ();
            });

            // when timer stops, turn timer state to false
            counter.on_stop.connect (() => {
                Hourglass.saved.timer_state = false;
            });

            // when counter ends
            counter.on_end.connect (() => {
                Hourglass.dbus_server.show_notification (_("Timer has ended!"), Counter.create_time_string (timer_value, false));
                Hourglass.saved.timer_state = false;
            });

            // update state
            Hourglass.saved.timer_state = true;
        }

        private void stop_timer () {
            stack.set_visible_child_name ("chooser_grid"); // set the chooser to be visible
            counter.stop (); // stop the counter
            counter.set_should_notify (false);

            var time = Counter.parse_seconds (counter.get_current_time ()); // get time from counter
            sec_chooser.set_value (time.seconds); // get second value from time and update spinner value
            min_chooser.set_value (time.minutes); // get minute value from time and update spinner value
            hour_chooser.set_value (time.hours); // get hour value from time and update spinner value

            // update state
            Hourglass.saved.timer_state = false;
        }

        public string get_id () {
            return "timer";
        }

        public string get_name () {
            return _("Timer");
        }

		public bool keep_open () {
			return counter.get_active ();
		}
    }

}
