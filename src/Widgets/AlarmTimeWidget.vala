/* Copyright 2015 Sam Thomas
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

using Hourglass.Dialogs;
using Hourglass.Window;
using Granite.Widgets;

namespace Hourglass.Widgets {

    public class AlarmTimeWidget : Gtk.Box, TimeWidget {

        private MainWindow window;

        // stack
        private Stack main_stack;

        // frame
        private Gtk.Frame frame;

        // welcome screen
        private Welcome no_alarm_screen;

        // list box
        private ScrolledWindow scrolled_window;
        private ListBox list_box;

        // action buttons
        private Button add_alarm;
        private Button edit_alarm;
        private Button settings;

        // dialogs
        private NewAlarmDialog new_alarm_dialog;

        // timeout id
        private uint timeout_id;

        // constructor
        public AlarmTimeWidget (MainWindow window) {
            Object (orientation: Orientation.VERTICAL, spacing: 0);

            this.window = window;

            // setup ui
            create_layout ();

            // connect signals
            connect_signals ();

            // update display
            update ();

            // load previously saved alarms
            load_alarms ();
        }

        private void create_layout () {
            main_stack = new Stack ();

            // welcome screen
            no_alarm_screen = new Welcome (_("No Alarms"), _("Click 'Add' to get started."));

            frame = new Gtk.Frame (null);
            frame.add (no_alarm_screen);
            frame.show_all ();

            main_stack.add_named (frame, "no-alarm-view");

            // alarm view
            scrolled_window = new ScrolledWindow (null, null);
            scrolled_window.vexpand = true;
            scrolled_window.hexpand = true;
            scrolled_window.margin_top = 12;

            list_box = new ListBox ();
            list_box.set_sort_func (sort_alarm_func);

            scrolled_window.add (list_box);

            frame = new Gtk.Frame (null);
            frame.add (scrolled_window);
            frame.show_all ();

            main_stack.add_named (frame, "alarm-view");

            // action buttons
            var button_box = new Box (Orientation.HORIZONTAL, 0);
            var add_edit_box = new Box (Orientation.HORIZONTAL, 12);

            add_alarm = new Button.with_label (_("Add"));
            // add_alarm.set_halign (Align.CENTER);

            edit_alarm = new Button.with_label (_("Edit"));
            // edit_alarm.set_halign (Align.CENTER);

            settings = new Button.from_icon_name ("emblem-system-symbolic");
            settings.set_halign (Align.END);

            add_edit_box.add (add_alarm);
            add_edit_box.add (edit_alarm);
            add_edit_box.set_halign (Align.CENTER);
            add_edit_box.set_hexpand (true);
            
            button_box.add (add_edit_box);
            button_box.add (settings);

            var grid = new Grid ();
            grid.row_spacing = 12;

            grid.attach (main_stack, 0, 0, 1, 1);
            grid.attach (button_box, 0, 1, 1, 1);
            this.pack_start (grid);
        }

        private void connect_signals () {
            add_alarm.clicked.connect (add_alarm_action);
            edit_alarm.clicked.connect (edit_alarm_action);
            list_box.row_selected.connect (update);

            Hourglass.dbus_server.should_refresh_client.connect (() => {
                load_alarms ();
                message ("Refresh");
            });

            // update display if alarm settings change
            // Hourglass.saved.changed.connect (load_alarms);
        }

        private void update () {
            list_box.show_all ();

            // loop through list box and see if there are still alarms in it
            var inc = list_box.get_children ().length ();

            if (inc == 0) {
                main_stack.set_visible_child_name ("no-alarm-view");

                // add small delay if daemon loads after application and list is empty
                if (Hourglass.saved.alarms.length != 0) {
                    timeout_id = Timeout.add (500, load_alarms_source_func);
                } else {
                    load_alarms ();
                }
            } else {
                main_stack.set_visible_child_name ("alarm-view");
            }

            edit_alarm.sensitive = (inc != 0 && list_box.get_selected_row () != null) ? true : false;
        }

        private void load_alarms () {
            clear_alarms ();
            foreach (string str in Hourglass.dbus_server.get_alarm_list ()) {
                if (Alarm.is_valid_alarm_string (str)) {
                    append_alarm (Alarm.parse_string (str));
                }
            }
        }

        private bool load_alarms_source_func () {
            load_alarms (); // load alarms

            // remove timeout
            if (list_box.get_children ().length () != 0) {
                Source.remove (timeout_id);
            }
            return false;
        }

        private void clear_alarms () {
            foreach (Widget w in list_box.get_children ()) {
                w.destroy ();
            }
        }

        private void append_alarm (Alarm a) {
            list_box.prepend (a);

            a.state_toggled.connect ((b) => {
                message ("toggled");
                Hourglass.dbus_server.toggle_alarm (a.to_string ());
            });

            Hourglass.dbus_server.add_alarm (a.to_string ());
            update ();
        }

        private void add_alarm_action () {
            new_alarm_dialog = new NewAlarmDialog (window);
            // connect create alarm signal
            new_alarm_dialog.create_alarm.connect ((a) => {
                append_alarm (a);
            });
            new_alarm_dialog.show_all ();
        }

        private void edit_alarm_action () {
            var widget = list_box.get_selected_row ();
            if (widget != null) {
                new_alarm_dialog = new NewAlarmDialog (window, (Alarm) widget);

                new_alarm_dialog.edit_alarm.connect ((old_a, new_a) => {
                    list_box.remove (old_a); //  remove old alarm
                    Hourglass.dbus_server.remove_alarm (old_a.to_string ());
                    append_alarm (new_a); // add new alarms
                });

                new_alarm_dialog.delete_alarm.connect ((a) => {
                    list_box.remove (a);
                    Hourglass.dbus_server.remove_alarm (a.to_string ());
                });
                new_alarm_dialog.show_all ();
            }
            update ();
        }

        private int sort_alarm_func (ListBoxRow row1, ListBoxRow row2) {
            if (row1 is Alarm && row2 is Alarm) {
                var time1 = ((Alarm) row1).time;
                var time2 = ((Alarm) row2).time;

                return time1.compare (time2);
            } else {
                return 0;
            }
        }

        public string get_id () {
            return "alarm";
        }

        public string get_name () {
            return _("Alarm");
        }
    }

}
