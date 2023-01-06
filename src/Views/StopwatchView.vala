/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2020 Sam Thomas
 *                         2020-2023 Ryo Nakano
 */

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

    [CCode (has_target = false)]
    private delegate bool KeyPressHandler (StopwatchView self, uint keyval, uint keycode, Gdk.ModifierType state);
    private static Gee.HashMap<uint, KeyPressHandler> key_press_handler;

    private Hourglass.Objects.Counter counter;
    private Gtk.Label counter_label;
    private Gtk.ListBox lap_box;
    private Gtk.Button start_button;
    private Gtk.Button stop_button;
    private Gtk.Button reset_button;
    private Gtk.Button lap_button;

    private string[] lap_log = {};
    private bool is_running = false;

    public StopwatchView (MainWindow window) {
        Object (
            window: window
        );
    }

    static construct {
        key_press_handler = new Gee.HashMap<uint, KeyPressHandler> ();
        key_press_handler[Gdk.Key.s] = key_press_handler_s;
    }

    construct {
        homogeneous = true;

        // add and configure counter
        counter = new Hourglass.Objects.Counter (Hourglass.Objects.Counter.CountDirection.UP);

        counter_label = new Gtk.Label (null) {
            margin_top = 10,
            margin_bottom = 10,
            margin_start = 10,
            margin_end = 10
        };
        counter_label.add_css_class ("timer");

        // create scollable log
        lap_box = new Gtk.ListBox ();
        var scrolled_window = new Gtk.ScrolledWindow () {
            vexpand = true,
            has_frame = true,
            child = lap_box
        };

        // create buttons
        start_button = new Gtk.Button.with_label (_("Start")) {
            tooltip_markup = Granite.markup_accel_tooltip ({"<Control>s"}, _("Start the stopwatch"))
        };
        start_button.add_css_class ("round-button");
        start_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        stop_button = new Gtk.Button.with_label (_("Stop")) {
            tooltip_markup = Granite.markup_accel_tooltip ({"<Control>s"}, _("Stop the stopwatch"))
        };
        stop_button.add_css_class ("round-button");
        stop_button.add_css_class ("red-button");

        reset_button = new Gtk.Button.with_label (_("Reset"));
        reset_button.add_css_class ("round-button");

        lap_button = new Gtk.Button.with_label (_("Lap"));
        lap_button.add_css_class ("round-button");

        var buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            spacing = 6,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        buttons_box.append (start_button);
        buttons_box.append (stop_button);
        buttons_box.append (reset_button);
        buttons_box.append (lap_button);

        append (counter_label);
        append (scrolled_window);
        append (buttons_box);

        var event_controller = new Gtk.EventControllerKey ();
        event_controller.key_pressed.connect ((keyval, keycode, state) => {
            var handler = key_press_handler[keyval];
            // Unhandled key event
            if (handler == null) {
                return false;
            }

            return handler (this, keyval, keycode, state);
        });
        add_controller (event_controller);

        counter.ticked.connect (update_counter_label);

        start_button.clicked.connect (start);
        stop_button.clicked.connect (stop);
        reset_button.clicked.connect (reset);
        lap_button.clicked.connect (lap);

        window.on_stack_change.connect (update);

        update ();
    }

    private void start () {
        counter.start ();
        is_running = true;
        update ();
    }

    private void stop () {
        counter.stop ();
        is_running = false;
        update ();
    }

    private void toggle () {
        if (is_running) {
            stop ();
        } else {
            start ();
        }
    }

    private void reset () {
        counter.reset ();
        lap_log = {};

        Gtk.ListBoxRow child;
        while ((child = (Gtk.ListBoxRow) lap_box.get_last_child ()) != null) {
            lap_box.remove (child);
        }

        update ();
    }

    private void lap () {
        string current_time = Hourglass.Utils.get_formatted_time (counter.current_time, true);
        lap_log += current_time;
        update_log ();
        update ();
    }

    private void update_counter_label () {
        string current_time = Hourglass.Utils.get_formatted_time (counter.current_time, true);
        counter_label.label = current_time;
    }

    private void update () {
        update_counter_label ();

        if (is_running) {
            start_button.hide ();
            stop_button.show ();
            reset_button.hide ();
            lap_button.show ();
        } else {
            start_button.show ();
            stop_button.hide ();
            reset_button.show ();
            lap_button.hide ();
        }

        reset_button.sensitive = (counter.current_time != 1);
    }

    private void update_log () {
        int i = get_index ();
        var label = new Gtk.Label ("%d: %s".printf (i + 1, lap_log[i])) {
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6
        };
        label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        var row = new Gtk.ListBoxRow () {
            child = label
        };

        lap_box.prepend (row);
    }

    private int get_index () {
        var last_child = lap_box.get_last_child () as Gtk.ListBoxRow;
        if (last_child == null) {
            return 0;
        }

        int last_index = last_child.get_index ();
        return last_index + 1;
    }

    private static bool key_press_handler_s (StopwatchView self, uint keyval, uint keycode, Gdk.ModifierType state) {
        if (!(Gdk.ModifierType.CONTROL_MASK in state)) {
            return false;
        }

        self.toggle ();
        return true;
    }
}
