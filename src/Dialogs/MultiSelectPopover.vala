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

using Hourglass.Widgets;

namespace Hourglass.Dialogs {

    public class MultiSelectPopover : Gtk.Popover {

        private ListBox list_box;

        //check buttons
        private CheckButton[] checks;

        private string[] days = {_("Sunday"), _("Monday"),
                            _("Tuesday"), _("Wednesday"),
                            _("Thursday"), _("Friday"), _("Saturday")};

        //private string[] shortened_days = {_("Sun"), _("Mon"), _("Tue"), _("Wed"), _("Thur"), _("Fri"), _("Sat")};

        //selected
        private int[] selected;

        public signal void on_finish (int[] selected, string display_string);

        public MultiSelectPopover (Gtk.Widget parent, int[]? selected = null) {
            this.set_relative_to (parent);

            set_modal (true);

            this.selected = selected;

            //create layout
            create_layout ();

            load_selected ();
        }

        private void create_layout () {
            list_box = new ListBox ();
            list_box.set_selection_mode (SelectionMode.NONE);

            checks = {};

            foreach (string s in days) {
                var c = new CheckButton.with_label (s);
                checks += c;
                list_box.insert (c, -1);
            }

            list_box.show_all ();

            this.add (list_box);
        }

        private void load_selected () {
            foreach (int i in selected) {
                var check = checks[i];
                check.active = true;
            }
        }

        public int[] get_selected () {
            selected = {};
            for (int i = 0; i < checks.length; i++) {
                if (checks[i].active == true) {
                   selected += i;
                }
            }

            return selected;
        }

        public string get_display_string () {
            get_selected ();
            return selected_to_string (selected);

        }

        public static string selected_to_string (int[] sel) {
            string[] shortened_days = {_("Sun"), _("Mon"), _("Tue"), _("Wed"), _("Thur"), _("Fri"), _("Sat")};

            var str = "";
            
            if (sel.length == 7) {
                str = _("Every Day");
            } else if (sel.length == 5 && !(0 in sel) && !(6 in sel)) {
                str = _("Every Weekday");
            } else if (sel.length == 2 && (0 in sel) && (6 in sel)) {
                str = _("Every Weekend");
            } else if (sel.length > 0) {
                foreach (int i in sel) {
                    str += shortened_days[i];
                    str += " ";
                }
            } else {
                str = _("Never");
            }
            return str;
        }
    }
}
