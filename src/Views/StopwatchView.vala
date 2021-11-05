/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2021 Sam Thomas
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
            margin = 10
        };
        counter_label.get_style_context ().add_class ("timer");

        // create scollable log
        lap_box = new Gtk.ListBox ();

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            vexpand = true,
            shadow_type = Gtk.ShadowType.IN
        };
        scrolled_window.add (lap_box);

        // create buttons
        start = new Gtk.Button.with_label (_("Start"));
        start.get_style_context ().add_class ("round-button");
        start.get_style_context ().add_class ("green-button");

        stop = new Gtk.Button.with_label (_("Stop"));
        stop.get_style_context ().add_class ("round-button");
        stop.get_style_context ().add_class ("red-button");

        reset = new Gtk.Button.with_label (_("Reset"));
        reset.get_style_context ().add_class ("round-button");

        lap = new Gtk.Button.with_label (_("Lap"));
        lap.get_style_context ().add_class ("round-button");

        var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.CENTER,
            spacing = 6,
            border_width = 12
        };
        button_box.add (start);
        button_box.add (stop);
        button_box.add (reset);
        button_box.add (lap);

        pack_start (counter_label);
        pack_start (scrolled_window);
        pack_start (button_box);

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
            foreach (var w in lap_box.get_children ()) {
                w.destroy ();
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
        var num = lap_box.get_children ().length ();
        var label = new Gtk.Label ("%u: %s".printf (num + 1, lap_log[num])) {
            margin = 6
        };
        label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var row = new Gtk.ListBoxRow ();
        row.add (label);

        lap_box.insert (row, 0);

        lap_box.show_all ();
    }
}
