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

namespace Hourglass.Widgets {

    public class StopwatchTimeWidget : Gtk.Box, TimeWidget {

        private MainWindow window;

        //countdown
        private Counter counter;

        //lap log
        private ScrolledWindow scrolled_window;
        private Box lap_box;
        private string[] lap_log;

        //buttons
        private Button start;
        private Button stop;
        private Button reset;
        private Button lap;

        //State
        private bool running;

        //constructor
        public StopwatchTimeWidget (MainWindow window) {
            Object (orientation: Orientation.VERTICAL, spacing: 0);
            running = false;
            this.window = window;

            //create and add box to widget
            create_layout ();

            //connect signals
            connect_signals ();

            update ();
        }

        public void create_layout () {
            //add and configure counter
            counter = new Counter (CountDirection.UP);
            counter.set_label_class ("timer");
            this.pack_start (counter.get_label ());

            //create scollable log
            lap_log = {};
            scrolled_window = new ScrolledWindow (null, null);
            scrolled_window.vexpand = true;
            var container_box = new Box (Orientation.VERTICAL, 0);

            lap_box = new Box (Orientation.VERTICAL, 0);
            lap_box.vexpand = false;
            container_box.pack_start (lap_box);

            var spacer = new Box (Orientation.VERTICAL, 0);
            spacer.vexpand = true;
            container_box.pack_start (spacer);

            scrolled_window.add (container_box);
			scrolled_window.vexpand = true;
			scrolled_window.shadow_type = Gtk.ShadowType.IN;
            this.pack_start (scrolled_window);

            //Create buttons
            var button_box = new ButtonBox (Orientation.HORIZONTAL);
            button_box.set_layout (Gtk.ButtonBoxStyle.CENTER);
            button_box.set_spacing (6);
            button_box.set_border_width (12);

            start = new Button.with_label (_("Start"));
            start.get_style_context ().add_class ("round-button");
            start.get_style_context ().add_class ("green-button");
            stop = new Button.with_label (_("Stop"));
            stop.get_style_context ().add_class ("round-button");
            stop.get_style_context ().add_class ("red-button");
            reset = new Button.with_label (_("Reset"));
            reset.get_style_context ().add_class ("round-button");
            lap = new Button.with_label (_("Lap"));
            lap.get_style_context ().add_class ("round-button");

            button_box.add (start);
            button_box.add (stop);
            button_box.add (reset);
            button_box.add (lap);

            this.pack_start (button_box, true, true, 0);
        }

        public string get_id () {
            return "stopwatch";
        }

        public string get_name () {
            return _("Stopwatch");
        }

        public void update () {
            //set visibility
            if (running) {
                start.hide ();
                stop.show ();
                reset.hide ();
                lap.show ();
            } else if (!running) {
                start.show ();
                stop.hide ();
                reset.show ();
                lap.hide ();
            }

            //set sensitivity
            reset.sensitive = counter.get_current_time () == 0 ? false : true;
        }

        private void update_log () {
            foreach (var w in lap_box.get_children ()) {
                w.destroy ();
            }
            foreach (var s in lap_log) {
                var num = lap_box.get_children ().length ()+ 1;
                var label = new Label (num.to_string () + ": " + s);
                label.get_style_context ().add_class ("log-text");
                label.show ();
                lap_box.pack_end (label);
            }
        }

        private void connect_signals () {
            start.clicked.connect (on_start_click);
            stop.clicked.connect (on_stop_click);
            reset.clicked.connect (on_reset_click);
            lap.clicked.connect (on_lap_click);

            window.on_stack_change.connect (update);
        }

        private void on_start_click () {
            counter.start ();
            running = true;
            update ();
        }

        private void on_stop_click () {
            counter.stop ();
            running = false;
            update ();
        }

        private void on_reset_click () {
            counter.set_current_time (0);
            lap_log = {};
            update_log ();
            update ();
        }

        private void on_lap_click () {
            lap_log += counter.get_time_string ();
            update_log ();
            update ();
        }
    }

}
