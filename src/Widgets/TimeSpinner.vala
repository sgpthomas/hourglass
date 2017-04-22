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

namespace Hourglass.Widgets {

    public class TimeSpinner : Gtk.SpinButton {

        public TimeSpinner (int limit) {
            //set adjustment of the time spinner
            var adj = new Adjustment (0, 0, limit, 1, 0, 0);
            this.configure (adj, 1, 0);
            this.set_numeric (true);

            //set the orientation of the spin button
            this.orientation = Orientation.VERTICAL;
            this.wrap = true;
            this.get_style_context ().add_class ("time-spinner"); //add some $tyle

            this.output.connect (() => {
                var val = this.get_value ();
                if (val < 10) {
                    this.set_text ("0" + val.to_string ());
                    return true;
                } else {
                    return false;
                }

            });
        }
    }
}
