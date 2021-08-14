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
            return counter.get_active ();
        }
    }

    public MainWindow window { get; construct; }

    private Counter counter;
    private Gtk.ListBox lap_box;
    private Gtk.Button start;
    private Gtk.Button stop;
    private Gtk.Button reset;
    private Gtk.Button lap;

    private string[] lap_log = {};
    private bool running = false;

    public StopwatchView (MainWindow window) {
        Object (window: window);
    }

    construct {
        // add and configure counter
        counter = new Counter (CountDirection.UP);
        counter.set_label_class ("timer");

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

        pack_start (counter.get_label ());
        pack_start (scrolled_window);
        pack_start (button_box);

        start.clicked.connect (() => {
            counter.start ();
            running = true;
            update ();
        });

        stop.clicked.connect (() => {
            counter.stop ();
            running = false;
            update ();
        });

        reset.clicked.connect (() => {
            counter.set_current_time (0);
            lap_log = {};
            foreach (var w in lap_box.get_children ()) {
                w.destroy ();
            }

            update ();
        });

        lap.clicked.connect (() => {
            lap_log += counter.get_time_string ();
            update_log ();
            update ();
        });

        window.on_stack_change.connect (update);

        update ();
    }

    private void update () {
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

        reset.sensitive = (counter.get_current_time () != 0);
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
