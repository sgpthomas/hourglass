/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2022 Sam Thomas
 */

using Hourglass.Widgets;
using Hourglass.Window;

public class Hourglass.Views.StopwatchView : AbstractView {
    public override string id {
        get {
            return "stopwatch";
        }
    }

    public override string display_name {
        get {
            return _("Stopwatch");
        }
    }

    public override bool should_keep_open {
        get {
            return counter.is_active;
        }
    }

    public MainWindow window { get; construct; }

    private Hourglass.Objects.Counter counter;
    private Gtk.Label counter_label;
    private Gtk.ListBox lap_box;
    private Gtk.Button start;
    private Gtk.Button stop;
    private Gtk.Button reset;
    private Gtk.Button lap;

    private string[] lap_log = {};
    private bool is_running = false;

    public StopwatchView (MainWindow window) {
        Object (window: window);
    }

    construct {
        // add and configure counter
        counter = new Hourglass.Objects.Counter (Hourglass.Objects.Counter.CountDirection.UP);

        counter_label = new Gtk.Label (Hourglass.Utils.get_formatted_time (counter.current_time, true)) {
            margin_top = 10,
            margin_bottom = 10,
            margin_start = 10,
            margin_end = 10
        };
        counter_label.get_style_context ().add_class ("timer");

        // create scollable log
        lap_box = new Gtk.ListBox ();

        var scrolled_window = new Gtk.ScrolledWindow () {
            vexpand = true,
            //  shadow_type = Gtk.ShadowType.IN
            has_frame = true,
            child = lap_box
        };

        // create buttons
        start = new Gtk.Button.with_label (_("Start"));
        start.get_style_context ().add_class ("round-button");
        start.get_style_context ().add_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        stop = new Gtk.Button.with_label (_("Stop"));
        stop.get_style_context ().add_class ("round-button");
        stop.get_style_context ().add_class ("red-button");

        reset = new Gtk.Button.with_label (_("Reset"));
        reset.get_style_context ().add_class ("round-button");

        lap = new Gtk.Button.with_label (_("Lap"));
        lap.get_style_context ().add_class ("round-button");

        var buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            spacing = 6,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        buttons_box.prepend (start);
        buttons_box.prepend (stop);
        buttons_box.prepend (reset);
        buttons_box.prepend (lap);

        prepend (counter_label);
        prepend (scrolled_window);
        prepend (buttons_box);

        counter.ticked.connect (() => {
            counter_label.label = Hourglass.Utils.get_formatted_time (counter.current_time, true);
        });

        start.clicked.connect (() => {
            counter.start ();
            is_running = true;
            update ();
        });

        stop.clicked.connect (() => {
            counter.stop ();
            is_running = false;
            update ();
        });

        reset.clicked.connect (() => {
            counter.reset ();
            lap_log = {};
            for (int i = 0; i <= ((Gtk.ListBoxRow) lap_box.get_last_child ()).get_index (); i++) {
                lap_box.remove (lap_box.get_row_at_index (i));
            }
    
            update ();
        });

        lap.clicked.connect (() => {
            lap_log += Hourglass.Utils.get_formatted_time (counter.current_time, true);
            update_log ();
            update ();
        });

        window.on_stack_change.connect (update);

        update ();
    }

    private void update () {
        counter_label.label = Hourglass.Utils.get_formatted_time (counter.current_time, true);

        if (is_running) {
            start.hide ();
            stop.show ();
            reset.hide ();
            lap.show ();
        } else if (!is_running) {
            start.show ();
            stop.hide ();
            reset.show ();
            lap.hide ();
        }

        reset.sensitive = (counter.current_time != 0);
    }

    private void update_log () {
        var num = ((Gtk.ListBoxRow) lap_box.get_last_child ()).get_index ();
        var label = new Gtk.Label ("%u: %s".printf (num + 1, lap_log[num])) {
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6
        };
        label.get_style_context ().add_class (Granite.STYLE_CLASS_DIM_LABEL);

        var row = new Gtk.ListBoxRow () {
            child = label
        };

        //  lap_box.insert (row, 0);
        lap_box.prepend (row);
    }
}
