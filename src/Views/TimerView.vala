/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2022 Sam Thomas
 */

using Hourglass.Widgets;

public class Hourglass.Views.TimerView : AbstractView {
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
            return counter.is_active;
        }
    }

    private Hourglass.Objects.Counter counter;

    private Gtk.Stack stack;

    private Gtk.SpinButton hour_chooser;
    private Gtk.SpinButton min_chooser;
    private Gtk.SpinButton sec_chooser;
    private Gtk.Entry purpose_entry;
    private Gtk.Button start_timer_button;
    private Gtk.Button reset_timer_button;

    private Gtk.Label counter_label;
    private Gtk.Button stop_timer_button;

    construct {
        // get current time from dconf
        Hourglass.Utils.Time time = Hourglass.Utils.parse_milliseconds (Hourglass.saved.get_int64 ("timer-time") * 100);

        hour_chooser = new Gtk.SpinButton (new Gtk.Adjustment (0, 0, 59, 1, 0, 0), 1, 0) {
            orientation = Gtk.Orientation.VERTICAL,
            wrap = true,
            numeric = true,
            value = time.hours,
            tooltip_text = _("Hours")
        };
        hour_chooser.get_style_context ().add_class ("timer");

        var hour_min_divider = new Gtk.Label (":");
        hour_min_divider.get_style_context ().add_class ("timer");

        min_chooser = new Gtk.SpinButton (new Gtk.Adjustment (0, 0, 59, 1, 0, 0), 1, 0) {
            orientation = Gtk.Orientation.VERTICAL,
            wrap = true,
            numeric = true,
            value = time.minutes,
            tooltip_text = _("Minutes")
        };
        min_chooser.get_style_context ().add_class ("timer");

        var min_second_divider = new Gtk.Label (":");
        min_second_divider.get_style_context ().add_class ("timer");

        sec_chooser = new Gtk.SpinButton (new Gtk.Adjustment (0, 0, 59, 1, 0, 0), 1, 0) {
            orientation = Gtk.Orientation.VERTICAL,
            wrap = true,
            numeric = true,
            value = time.seconds,
            tooltip_text = _("Seconds")
        };
        sec_chooser.get_style_context ().add_class ("timer");

        purpose_entry = new Gtk.Entry () {
            placeholder_text = _("Enter purposes of the timer"),
            margin_bottom = 12
        };

        start_timer_button = new Gtk.Button.with_label (_("Start"));
        start_timer_button.get_style_context ().add_class ("round-button");
        start_timer_button.get_style_context ().add_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        reset_timer_button = new Gtk.Button.with_label (_("Reset"));
        reset_timer_button.get_style_context ().add_class ("round-button");

        // chooser grid
        var chooser_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            column_spacing = 6,
            row_spacing = 12
        };
        chooser_grid.attach (hour_chooser, 0, 0, 1, 1);
        chooser_grid.attach (hour_min_divider, 1, 0, 1, 1);
        chooser_grid.attach (min_chooser, 2, 0, 1, 1);
        chooser_grid.attach (min_second_divider, 3, 0, 1, 1);
        chooser_grid.attach (sec_chooser, 4, 0, 1, 1);
        chooser_grid.attach (purpose_entry, 0, 1, 5, 1);
        chooser_grid.attach (start_timer_button, 0, 2, 5, 1);
        chooser_grid.attach (reset_timer_button, 0, 3, 5, 1);

        // configure counter
        counter = new Hourglass.Objects.Counter (Hourglass.Objects.Counter.CountDirection.DOWN);

        counter_label = new Gtk.Label (Hourglass.Utils.get_formatted_time (counter.current_time, false)) {
            margin_top = 10,
            margin_bottom = 10,
            margin_start = 10,
            margin_end = 10
        };
        counter_label.get_style_context ().add_class ("timer");

        stop_timer_button = new Gtk.Button.with_label (_("Stop"));
        stop_timer_button.get_style_context ().add_class ("round-button");
        stop_timer_button.get_style_context ().add_class ("red-button");

        // timer grid
        var timer_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            column_spacing = 6,
            row_spacing = 12
        };
        timer_grid.attach (counter_label, 0, 0, 1, 1);
        timer_grid.attach (stop_timer_button, 0, 1, 1, 1);

        // add grids to the stack
        stack = new Gtk.Stack () {
            valign = Gtk.Align.CENTER,
            vexpand = true
        };
        stack.add_named (chooser_grid, "chooser_grid");
        stack.add_named (timer_grid, "timer_grid");

        prepend (stack);

        sec_chooser.value_changed.connect (() => {
            Hourglass.saved.set_int64 ("timer-time", (int64) ((hour_chooser.get_value () * 3600) + (min_chooser.get_value () * 60) + sec_chooser.get_value ()));
            if (sec_chooser.value < 10) {
                sec_chooser.text = "0%i".printf ((int) sec_chooser.value);
            }

            update ();
        });

        min_chooser.value_changed.connect (() => {
            Hourglass.saved.set_int64 ("timer-time", (int64) ((hour_chooser.get_value () * 3600) + (min_chooser.get_value () * 60) + sec_chooser.get_value ()));
            if (min_chooser.value < 10) {
                min_chooser.text = "0%i".printf ((int) min_chooser.value);
            }

            update ();
        });

        hour_chooser.value_changed.connect (() => {
            Hourglass.saved.set_int64 ("timer-time", (int64) ((hour_chooser.get_value () * 3600) + (min_chooser.get_value () * 60) + sec_chooser.get_value ()));
            if (hour_chooser.value < 10) {
                hour_chooser.text = "0%i".printf ((int) hour_chooser.value);
            }

            update ();
        });

        purpose_entry.changed.connect (update);

        start_timer_button.clicked.connect (start_timer);

        reset_timer_button.clicked.connect (clear_timer);

        stop_timer_button.clicked.connect (stop_timer);

        counter.ticked.connect (() => {
            counter_label.label = Hourglass.Utils.get_formatted_time (counter.current_time, false);
        });

        counter.ended.connect (stop_timer);

        update ();
        hour_chooser.grab_focus ();

        // resume state
        if (Hourglass.saved.get_boolean ("timer-state")) {
            start_timer ();
        }
    }

    private void update () {
        // set sensitivity of the start button and clear button
        bool is_timer_non_zero = !(sec_chooser.get_value () == 0 && min_chooser.get_value () == 0 && hour_chooser.get_value () == 0);
        start_timer_button.sensitive = is_timer_non_zero;
        reset_timer_button.sensitive = is_timer_non_zero || purpose_entry.text != "";
    }

    private void start_timer () {
        stack.set_visible_child_name ("timer_grid");

        var val = (int64) (sec_chooser.get_value () + (min_chooser.get_value () * 60) + (hour_chooser.get_value () * 3600)) * 1000000;
        counter.limit = val;
        counter.should_notify = true;
        counter.set_notification (
            purpose_entry.text == "" ? _("It's time!") : purpose_entry.text,
            Hourglass.Utils.get_formatted_time (val, false),
            "timer"
        );

        debug ("starting");
        counter.start ();

        counter.ticked.connect (() => {
            update ();
        });

        // when timer stops, turn timer state to false
        counter.stopped.connect (() => {
            Hourglass.saved.set_int64 ("timer-time", counter.current_time / 1000);
            Hourglass.saved.set_boolean ("timer-state", false);
        });

        // when counter ends
        counter.ended.connect (() => {
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
        purpose_entry.text = "";
    }

    private void stop_timer () {
        stack.set_visible_child_name ("chooser_grid"); // set the chooser to be visible
        counter.stop (); // stop the counter
        counter.should_notify = false;

        Hourglass.Utils.Time time = Hourglass.Utils.parse_milliseconds (counter.current_time); // get time from counter
        sec_chooser.value = time.seconds; // get second value from time and update spinner value
        min_chooser.value = time.minutes; // get minute value from time and update spinner value
        hour_chooser.value = time.hours; // get hour value from time and update spinner value

        // update state
        Hourglass.saved.set_boolean ("timer-state", false);
    }
}
