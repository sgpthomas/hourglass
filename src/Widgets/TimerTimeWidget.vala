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

using Hourglass.Widgets;

public class Hourglass.Widgets.TimerTimeWidget : TimeWidget {
    public override string id {
        get {
            return "timer";
        }
    }

    public override string display_name {
        get {
            return _("Timer");
        }
    }

    public override bool should_keep_open {
        get {
            return counter.get_active ();
        }
    }

    private Counter counter;

    // containers
    private Gtk.Stack stack;

    // elements
    private TimeSpinner hour_chooser;
    private TimeSpinner min_chooser;
    private TimeSpinner sec_chooser;
    private Gtk.Button start_timer_button;
    private Gtk.Button reset_timer_button;
    private Gtk.Button stop_timer_button;

    construct {
        // get current time from dconf
        Counter.Time t = Counter.parse_seconds (Hourglass.saved.get_int64 ("timer-time") * 100);

        hour_chooser = new TimeSpinner (59) {
            value = t.hours,
            tooltip_text = _("Hours")
        };

        min_chooser = new TimeSpinner (59) {
            value = t.minutes,
            tooltip_text = _("Minutes")
        };

        sec_chooser = new TimeSpinner (59) {
            value = t.seconds,
            tooltip_text = _("Seconds")
        };

        start_timer_button = new Gtk.Button.with_label (_("Start"));
        start_timer_button.get_style_context ().add_class ("round-button");
        start_timer_button.get_style_context ().add_class ("green-button");

        reset_timer_button = new Gtk.Button.with_label (_("Reset"));
        reset_timer_button.get_style_context ().add_class ("round-button");

        // chooser grid
        var chooser_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            column_spacing = 6,
            row_spacing = 12
        };
        chooser_grid.attach (hour_chooser, 0, 0, 1, 1);
        chooser_grid.attach (new Gtk.Label (":"), 1, 0, 1, 1);
        chooser_grid.attach (min_chooser, 2, 0, 1, 1);
        chooser_grid.attach (new Gtk.Label (":"), 3, 0, 1, 1);
        chooser_grid.attach (sec_chooser, 4, 0, 1, 1);
        chooser_grid.attach (start_timer_button, 0, 1, 5, 1);
        chooser_grid.attach (reset_timer_button, 0, 2, 5, 1);

        // configure counter
        counter = new Counter (CountDirection.DOWN);
        counter.set_label_class ("timer");

        stop_timer_button = new Gtk.Button.with_label (_("Stop"));
        stop_timer_button.get_style_context ().add_class ("round-button");
        stop_timer_button.get_style_context ().add_class ("red-button");

        // timer grid
        var timer_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            column_spacing = 6,
            row_spacing = 12
        };
        timer_grid.attach (counter.get_label (false), 0, 0, 1, 1);
        timer_grid.attach (stop_timer_button, 0, 1, 1, 1);

        // add grids to the stack
        stack = new Gtk.Stack () {
            valign = Gtk.Align.CENTER,
            vexpand = true
        };
        stack.add_named (chooser_grid, "chooser_grid");
        stack.add_named (timer_grid, "timer_grid");

        add (stack);

        sec_chooser.value_changed.connect (() => {
            Hourglass.saved.set_int64 ("timer-time", (int64) ((hour_chooser.get_value () * 3600) + (min_chooser.get_value () * 60) + sec_chooser.get_value ()));
            update ();
        });

        min_chooser.value_changed.connect (() => {
            Hourglass.saved.set_int64 ("timer-time", (int64) ((hour_chooser.get_value () * 3600) + (min_chooser.get_value () * 60) + sec_chooser.get_value ()));
            update ();
        });

        hour_chooser.value_changed.connect (() => {
            Hourglass.saved.set_int64 ("timer-time", (int64) ((hour_chooser.get_value () * 3600) + (min_chooser.get_value () * 60) + sec_chooser.get_value ()));
            update ();
        });

        start_timer_button.clicked.connect (start_timer);

        reset_timer_button.clicked.connect (clear_timer);

        stop_timer_button.clicked.connect (stop_timer);

        counter.on_end.connect (stop_timer);

        update ();

        // resume state
        if (Hourglass.saved.get_boolean ("timer-state")) {
            start_timer ();
        }
    }

    private void update () {
        // set sensitivity of the start button and clear button
        bool is_timer_non_zero = !(sec_chooser.get_value () == 0 && min_chooser.get_value () == 0 && hour_chooser.get_value () == 0);
        start_timer_button.sensitive = is_timer_non_zero;
        reset_timer_button.sensitive = is_timer_non_zero;
    }

    private void start_timer () {
        stack.set_visible_child_name ("timer_grid");

        var val = (int64) (sec_chooser.get_value () + (min_chooser.get_value () * 60) + (hour_chooser.get_value () * 3600)) * 1000000;
        counter.set_limit (val);
        counter.set_should_notify (true, _("Timer has ended!"), Counter.create_time_string (val, false));

        debug ("starting");
        counter.start ();

        counter.on_tick.connect (() => {
            update ();
        });

        // when timer stops, turn timer state to false
        counter.on_stop.connect (() => {
            Hourglass.saved.set_int64 ("timer-time", counter.get_current_time () / 1000);
            Hourglass.saved.set_boolean ("timer-state", false);
        });

        // when counter ends
        counter.on_end.connect (() => {
            Hourglass.saved.set_int64 ("timer-time", 0);
            Hourglass.saved.set_boolean ("timer-state", false);
        });

        // update state
        Hourglass.saved.set_boolean ("timer-state", true);
    }

    private void clear_timer () {
        sec_chooser.value = 0;
        min_chooser.value = 0;
        hour_chooser.value = 0;
    }

    private void stop_timer () {
        stack.set_visible_child_name ("chooser_grid"); // set the chooser to be visible
        counter.stop (); // stop the counter
        counter.set_should_notify (false);

        var time = Counter.parse_seconds (counter.get_current_time ()); // get time from counter
        sec_chooser.value = time.seconds; // get second value from time and update spinner value
        min_chooser.value = time.minutes; // get minute value from time and update spinner value
        hour_chooser.value = time.hours; // get hour value from time and update spinner value

        // update state
        Hourglass.saved.set_boolean ("timer-state", false);
    }
}
