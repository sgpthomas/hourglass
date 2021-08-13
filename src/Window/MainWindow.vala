/*
* Copyright 2015-2020 Sam Thomas
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

public class Hourglass.Window.MainWindow : Gtk.Window {
    public signal void on_stack_change ();

    private Gtk.Stack stack;
    private Hourglass.Widgets.TimeWidget[] widget_list;

    private string last_visible;

    public MainWindow () {
        Object (
            title: _("Hourglass")
        );
    }

    construct {
        set_border_width (12);

        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/com/github/sgpthomas/hourglass/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        stack = new Gtk.Stack ();
        var stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.stack = stack;
        stack_switcher.halign = Gtk.Align.CENTER;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        //add time widgets
        widget_list += new Hourglass.Widgets.AlarmTimeWidget (this);
        widget_list += new Hourglass.Widgets.StopwatchTimeWidget (this);
        widget_list += new Hourglass.Widgets.TimerTimeWidget ();

        var headerbar = new Gtk.HeaderBar ();
        headerbar.set_custom_title (stack_switcher);
        headerbar.show_close_button = true;
        this.set_titlebar (headerbar);

        //loop through time widgets
        foreach (Hourglass.Widgets.TimeWidget widget in widget_list) {
            stack.add_titled (widget, widget.id, widget.display_name);
        }

        add (stack);

        // Follow elementary OS-wide dark preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        show_all ();

        stack.notify.connect ((s, p) => {
            if (last_visible != stack.get_visible_child_name () &&
                    stack.get_visible_child () != null &&
                    Hourglass.main_window != null) {
                last_visible = stack.get_visible_child_name ();
                on_stack_change ();

                Hourglass.saved.set_string ("last-open-widget", last_visible);
            }
        });

        this.delete_event.connect (() => {
            on_delete ();
        });

        stack.visible_child_name = Hourglass.saved.get_string ("last-open-widget");
    }

    protected override bool key_press_event (Gdk.EventKey key) {
        if (Gdk.ModifierType.CONTROL_MASK in key.state) {
            switch (key.keyval) {
                case Gdk.Key.q:
                    on_delete ();
                    break;
            }
        }

        return Gdk.EVENT_PROPAGATE;
    }

    private bool on_delete () {
        int window_width, window_height, window_x, window_y;
        get_size (out window_width, out window_height);
        get_position (out window_x, out window_y);
        Hourglass.saved.set ("window-size", "(ii)", window_width, window_height);
        Hourglass.saved.set ("window-position", "(ii)", window_x, window_y);
        Hourglass.saved.set_boolean ("is-maximized", is_maximized);

        var visible = (Hourglass.Widgets.TimeWidget) stack.get_visible_child ();
        if (visible.should_keep_open) {
            Hourglass.window_open = false;
            iconify ();
            return false;
        } else {
            Gtk.main_quit ();
            return true;
        }
    }
}
