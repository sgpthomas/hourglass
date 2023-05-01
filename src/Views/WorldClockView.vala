/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Ryo Nakano
 */

public class Hourglass.Views.WorldClockView : AbstractView {
    public override string id {
        get {
            return "world-clock";
        }
    }

    public override string display_name {
        get {
            return _("World Clock");
        }
    }

    public override bool should_keep_open {
        get {
            return false;
        }
    }

    construct {
    }
}
