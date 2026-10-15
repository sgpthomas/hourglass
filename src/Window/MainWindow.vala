/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2020 Sam Thomas
 *                         2020-2026 Ryo Nakano
 */

public class Hourglass.Window.MainWindow : Gtk.ApplicationWindow {
    public signal void on_stack_change ();

    private Gtk.Stack stack;
    private Hourglass.Views.AbstractView[] widget_list;

    public MainWindow (Gtk.Application app) {
        Object (
            title: "Hourglass",
            application: app
        );
    }

    construct {
        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/com/github/sgpthomas/hourglass/Application.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        stack = new Gtk.Stack () {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        };

        var stack_switcher = new Gtk.StackSwitcher () {
            stack = stack,
            halign = Gtk.Align.CENTER
        };

        //add time widgets
        widget_list += new Hourglass.Views.AlarmView (this);
        widget_list += new Hourglass.Views.StopwatchView (this);
        widget_list += new Hourglass.Views.TimerView ();

        //loop through time widgets
        foreach (Hourglass.Views.AbstractView widget in widget_list) {
            stack.add_titled (widget, widget.id, widget.display_name);
        }

        var headerbar = new Gtk.HeaderBar () {
            title_widget = stack_switcher
        };
        headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);
        set_titlebar (headerbar);

        child = stack;

        var event_controller = new Gtk.EventControllerKey ();
        event_controller.key_pressed.connect ((keyval, keycode, state) => {
            if (Gdk.ModifierType.CONTROL_MASK in state && keyval == Gdk.Key.q) {
                close_request ();
                return true;
            }

            return false;
        });
        ((Gtk.Widget) this).add_controller (event_controller);

        stack.notify["visible-child"].connect (() => {
            Hourglass.saved.set_string ("last-open-widget", stack.visible_child_name);
            on_stack_change ();
        });

        stack.visible_child_name = Hourglass.saved.get_string ("last-open-widget");
    }

    protected override bool close_request () {
        var visible = (Hourglass.Views.AbstractView) stack.get_visible_child ();
        if (visible.should_keep_open) {
            ((Gtk.Widget) this).visible = false;

            /*
             * Prevent other handlers from being invoked to destroy the window
             * because we've change visibility instead of destroying
             */
            return true;
        }

        // We have to wrap in Idle otherwise we crash because libportal hasn't unexported us yet
        ((HourglassApp) application).request_background.begin (() =>
            Idle.add_once (() => destroy ())
        );

        /*
         * Prevent other handlers from being invoked to destroy the window
         * because we've scheduled destroy on our own
         */
        return true;
    }
}
