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

namespace Hourglass.Services {

    public class SavedState : Granite.Services.Settings {

        // app state
        public string last_open_widget {get; set;}
        public string[] alarms {get; set;}
        public int timer_time {get; set;}
        public bool timer_state {get; set;}

        // window state
        public int window_width {get; set;}
        public int window_height {get; set;}

        public SavedState () {
            base ("org.pantheon.hourglass.saved");
        }
    }

    public class SystemTimeFormat : Granite.Services.Settings {

        public string clock_format {get; set;}

        public SystemTimeFormat () {
            base ("org.gnome.desktop.interface");
        }
    }
}
