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

using Gtk;
using Granite.Widgets;

using Hourglass.Widgets;
using Hourglass.Services;

namespace Hourglass.Window {

    public class MainWindow : Gtk.Window {

        //signals

        //app instance
        private HourglassApp app;

        //header bar stuff
        private HeaderBar headerbar;
        //menu items

        //stacks
        private Stack stack;
        private StackSwitcher stack_switcher;

        //time widgets
        private TimeWidget[] widget_list;

        //last visible widget
        private string last_visible;

        //signals
        public signal void on_stack_change ();

        //constructor
        public MainWindow (HourglassApp app) {
            //set some variables of gtk.window
            this.app = app;
            this.title = Constants.APP_NAME;
            this.set_border_width (12);

            //initiate stylesheet
            StyleManager.add_stylesheet ("style/text.css");
            StyleManager.add_stylesheet ("style/elements.css");

            //stack init
            stack = new Stack ();
            stack_switcher = new StackSwitcher ();
            stack_switcher.set_stack (stack);
            stack_switcher.set_halign (Align.CENTER);

            //add time widgets
            widget_list += new AlarmTimeWidget (this);
            widget_list += new StopwatchTimeWidget (this);
            widget_list += new TimerTimeWidget (this);

            setup_headerbar ();

            setup_layout ();

            //show all widgets
            show_all ();

            connect_signals ();

            stack.set_visible_child_name (Hourglass.saved.get_string ("last-open-widget"));
        }

        private void setup_headerbar () {
            //headerbar
            headerbar = new HeaderBar ();
            headerbar.set_custom_title (stack_switcher);
            headerbar.set_show_close_button (true);
            this.set_titlebar (headerbar);
        }

        private void setup_layout () {
            //loop through time widgets
            foreach (TimeWidget t in widget_list) {
                stack.add_titled (t, t.get_id (), t.get_name ());
                stack.set_transition_type (StackTransitionType.SLIDE_LEFT_RIGHT);
            }

            var main_box = new Box (Orientation.VERTICAL, 0);
            //main_box.pack_start (stack_switcher, false, false, 0);
            main_box.pack_start (stack, true, true, 0);

            this.add (main_box);

        }

        private void connect_signals () {
            stack.notify.connect ((s, p) => {
                if (last_visible != stack.get_visible_child_name () && stack.get_visible_child () != null && Hourglass.main_window != null) {
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

				var visible = (TimeWidget) stack.get_visible_child ();
				if (visible.keep_open ()) {
					Hourglass.window_open = false;
					this.iconify ();
					return false;
				} else {
					Gtk.main_quit ();
					return true;
				}

            });
        }
    }
}
