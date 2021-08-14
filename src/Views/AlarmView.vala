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

public class Hourglass.Views.AlarmView : AbstractView {
    public override string id {
        get {
            return "alarm";
        }
    }

    public override string display_name {
        get {
            return _("Alarm");
        }
    }

    public override string icon_name {
        get {
            return "preferences-system-time";
        }
    }

    public override bool should_keep_open {
        get {
            return false;
        }
    }

    public Hourglass.Window.MainWindow window { get; construct; }

    private Gtk.Stack stack;
    private Gtk.ListBox list_box;
    private Gtk.Button edit_alarm_button;
    private Gtk.Button delete_alarm_button;

    private uint timeout_id;

    public AlarmView (Hourglass.Window.MainWindow window) {
        Object (window: window);
    }

    construct {
        // welcome screen
        var no_alarm_screen = new Granite.Widgets.Welcome (
            _("No Alarms"), _("Click the add icon in the toolbar below to get started.")
        );

        // alarm view
        list_box = new Gtk.ListBox ();
        list_box.set_sort_func (sort_alarm_func);

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            vexpand = true,
            hexpand = true
        };
        scrolled_window.add (list_box);

        stack = new Gtk.Stack ();
        stack.add_named (no_alarm_screen, "no-alarm-view");
        stack.add_named (scrolled_window, "alarm-view");

        // action buttons
        var add_alarm_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON);
        add_alarm_button.tooltip_text = _("Add…");

        edit_alarm_button = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON);
        edit_alarm_button.tooltip_text = _("Edit…");

        delete_alarm_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON);
        delete_alarm_button.tooltip_text = _("Delete");

        var actionbar = new Gtk.ActionBar ();
        actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        actionbar.add (add_alarm_button);
        actionbar.add (edit_alarm_button);
        actionbar.add (delete_alarm_button);

        get_style_context ().add_class ("frame");
        pack_start (stack);
        pack_start (actionbar, false);

        list_box.row_selected.connect (update);

        add_alarm_button.clicked.connect (() => {
            var new_alarm_dialog = new Hourglass.Dialogs.NewAlarmDialog (window);
            new_alarm_dialog.create_alarm.connect ((alarm) => {
                append_alarm (alarm);
            });
            new_alarm_dialog.show_all ();
        });

        edit_alarm_button.clicked.connect (edit_alarm_action);

        delete_alarm_button.clicked.connect (() => {
            unowned Alarm alarm = ((Alarm) list_box.get_selected_row ());
            list_box.remove (alarm);
            try {
                Hourglass.dbus_server.remove_alarm (alarm.to_string ());
            } catch (GLib.Error e) {
                error (e.message);
            }
        });

        Hourglass.dbus_server.should_refresh_client.connect (() => {
            load_alarms ();
            debug ("Refresh");
        });

        update ();

        // load previously saved alarms
        load_alarms ();
    }

    private void update () {
        list_box.show_all ();

        // loop through list box and see if there are still alarms in it
        var inc = list_box.get_children ().length ();

        if (inc == 0) {
            stack.set_visible_child_name ("no-alarm-view");

            // add small delay if daemon loads after application and list is empty
            if (Hourglass.saved.get_strv ("alarms").length != 0) {
                timeout_id = Timeout.add (500, load_alarms_source_func);
            } else {
                load_alarms ();
            }
        } else {
            stack.set_visible_child_name ("alarm-view");
        }

        bool has_alarm = (inc != 0 && list_box.get_selected_row () != null);
        edit_alarm_button.sensitive = has_alarm;
        delete_alarm_button.sensitive = has_alarm;
    }

    private void load_alarms () {
        // Clear alarms
        foreach (Gtk.Widget w in list_box.get_children ()) {
            w.destroy ();
        }

        try {
            foreach (string str in Hourglass.dbus_server.get_alarm_list ()) {
                if (Alarm.is_valid_alarm_string (str)) {
                    append_alarm (Alarm.parse_string (str));
                }
            }
        } catch (GLib.Error e) {
            error (e.message);
        }
    }

    private bool load_alarms_source_func () {
        load_alarms ();

        // remove timeout
        if (list_box.get_children ().length () != 0) {
            GLib.Source.remove (timeout_id);
        }

        return false;
    }

    private void append_alarm (Alarm alarm) {
        list_box.prepend (alarm);

        alarm.state_toggled.connect (() => {
            debug ("toggled");
            try {
                Hourglass.dbus_server.toggle_alarm (alarm.to_string ());
            } catch (Error e) {
                error (e.message);
            }
        });

        try {
            Hourglass.dbus_server.add_alarm (alarm.to_string ());
        } catch (GLib.Error e) {
            error (e.message);
        }

        update ();
    }

    private void edit_alarm_action () {
        var widget = list_box.get_selected_row ();
        if (widget != null) {
            var new_alarm_dialog = new Hourglass.Dialogs.NewAlarmDialog (window, (Alarm) widget);

            new_alarm_dialog.edit_alarm.connect ((old_a, new_a) => {
                list_box.remove (old_a); //  remove old alarm
                try {
                    Hourglass.dbus_server.remove_alarm (old_a.to_string ());
                } catch (GLib.Error e) {
                    error (e.message);
                }

                append_alarm (new_a); // add new alarms
            });

            new_alarm_dialog.show_all ();
        }

        update ();
    }

    private int sort_alarm_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        if (row1 is Alarm && row2 is Alarm) {
            var time1 = ((Alarm) row1).time;
            var time2 = ((Alarm) row2).time;

            return time1.compare (time2);
        } else {
            return 0;
        }
    }
}
