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

    //time widgets
    private Hourglass.Widgets.TimeWidget[] widget_list;

    private string last_visible;

    public MainWindow () {
    }

    construct {
        title = Constants.APP_NAME;
        set_border_width (12);

        //initiate stylesheet
        Hourglass.Services.StyleManager.add_stylesheet ("style/text.css");
        Hourglass.Services.StyleManager.add_stylesheet ("style/elements.css");

        var stack = new Gtk.Stack ();
        var stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.stack = stack;
        stack_switcher.halign = Gtk.Align.CENTER;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        //add time widgets
        widget_list += new Hourglass.Widgets.AlarmTimeWidget (this);
        widget_list += new Hourglass.Widgets.StopwatchTimeWidget (this);
        widget_list += new Hourglass.Widgets.TimerTimeWidget (this);

        var headerbar = new Gtk.HeaderBar ();
        headerbar.set_custom_title (stack_switcher);
        headerbar.show_close_button = true;
        this.set_titlebar (headerbar);

        //loop through time widgets
        foreach (Hourglass.Widgets.TimeWidget t in widget_list) {
            stack.add_titled (t, t.get_id (), t.get_name ());
        }

        add (stack);

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

        // remove gtk loop on destroy window
        this.delete_event.connect (() => {
            // save size of window on close
            int window_width, window_height, window_x, window_y;
            get_size (out window_width, out window_height);
            get_position (out window_x, out window_y);
            Hourglass.saved.set ("window-size", "(ii)", window_width, window_height);
            Hourglass.saved.set ("window-position", "(ii)", window_x, window_y);
            Hourglass.saved.set_boolean ("is-maximized", this.is_maximized);

            var visible = (Hourglass.Widgets.TimeWidget) stack.get_visible_child ();
            if (visible.keep_open ()) {
                Hourglass.window_open = false;
                this.iconify ();
                return false;
            } else {
                Gtk.main_quit ();
                return true;
            }

        });

        stack.visible_child_name = Hourglass.saved.get_string ("last-open-widget");
    }
}
