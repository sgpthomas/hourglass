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

public class Hourglass.Window.MainWindow : Hdy.Window {
    public signal void on_stack_change ();

    private Gtk.Stack stack;
    private Hourglass.Views.AbstractView[] widget_list;

    public MainWindow () {
        Object (
            title: _("Hourglass")
        );
    }

    construct {
        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/com/github/sgpthomas/hourglass/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        stack = new Gtk.Stack ();
        stack.border_width = 12;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        var stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.stack = stack;
        stack_switcher.halign = Gtk.Align.CENTER;

        //add time widgets
        widget_list += new Hourglass.Views.AlarmView (this);
        widget_list += new Hourglass.Views.StopwatchView (this);
        widget_list += new Hourglass.Views.TimerView ();

        //loop through time widgets
        foreach (Hourglass.Views.AbstractView widget in widget_list) {
            stack.add_titled (widget, widget.id, widget.display_name);
        }

        var headerbar = new Hdy.HeaderBar ();
        headerbar.custom_title = stack_switcher;
        headerbar.show_close_button = true;

        unowned var headerbar_style = headerbar.get_style_context ();
        headerbar_style.add_class (Gtk.STYLE_CLASS_FLAT);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.add (headerbar);
        main_box.add (stack);

        add (main_box);

        // Follow elementary OS-wide dark preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        show_all ();

        stack.notify["visible-child"].connect (() => {
            Hourglass.saved.set_string ("last-open-widget", stack.visible_child_name);
            on_stack_change ();
        });

        delete_event.connect (() => {
            on_delete ();
            return true;
        });

        key_press_event.connect ((key) => {
            if (Gdk.ModifierType.CONTROL_MASK in key.state && key.keyval == Gdk.Key.q) {
                on_delete ();
            }

            return false;
        });

        stack.visible_child_name = Hourglass.saved.get_string ("last-open-widget");
    }

    private bool on_delete () {
        int window_width, window_height, window_x, window_y;
        get_size (out window_width, out window_height);
        get_position (out window_x, out window_y);
        Hourglass.saved.set ("window-size", "(ii)", window_width, window_height);
        Hourglass.saved.set ("window-position", "(ii)", window_x, window_y);
        Hourglass.saved.set_boolean ("is-maximized", is_maximized);

        var visible = (Hourglass.Views.AbstractView) stack.get_visible_child ();
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
