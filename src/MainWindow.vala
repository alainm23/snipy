/*
* Copyright (c) 2017 Daniel Foré (http://danielfore.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class MainWindow : Hdy.Window {
    private Gtk.Paned paned_start;
    private Gtk.Paned paned_end;

    private Widgets.Welcome welcome;
    private Widgets.Sidebar sidebar;
    private Widgets.Snippets snippets;

    private uint configure_id = 0;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.alainm23.snipy",
            title: _("Snipy")
        );
    }

    construct {
        Hdy.init ();

        sidebar = new Widgets.Sidebar ();
        snippets = new Widgets.Snippets ();

        var code_header = new Hdy.HeaderBar ();
        code_header.decoration_layout = ":maximise";
        code_header.has_subtitle = false;
        code_header.show_close_button = true;
        code_header.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var code_label = new Gtk.Label ("Code");
        code_label.expand = true;

        var code_grid = new Gtk.Grid ();
        code_grid.expand = true;
        code_grid.orientation = Gtk.Orientation.VERTICAL;
        code_grid.add (code_header);
        code_grid.add (code_label);

        paned_start = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned_start.pack1 (sidebar, false, false);
        paned_start.pack2 (snippets, true, false);

        paned_end = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned_end.pack1 (paned_start, false, false);
        paned_end.pack2 (code_grid, true, true);

        welcome = new Widgets.Welcome ();

        var main_stack = new Gtk.Stack ();
        main_stack.expand = true;
        main_stack.transition_type = Gtk.StackTransitionType.NONE;

        main_stack.add_named (welcome, "welcome");
        main_stack.add_named (paned_end, "main");

        add (main_stack);

        Snipy.settings.bind ("paned-start-position", paned_start, "position", SettingsBindFlags.DEFAULT);
        Snipy.settings.bind ("paned-end-position", paned_end, "position", SettingsBindFlags.DEFAULT);

        welcome.activated.connect ((index) => {
            switch (index) {
                case 0:
                    main_stack.visible_child_name = "main";
                    break;
                case 1:
                    var oauth = new Dialogs.GitHubOAuth ();
                    oauth.show_all ();
                    break;
                default:
                    break;
                }
        });
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;
            
            Gdk.Rectangle rect;
            get_allocation (out rect);
            Snipy.settings.set ("window-size", "(ii)", rect.width, rect.height);

            int root_x, root_y;
            get_position (out root_x, out root_y);
            Snipy.settings.set ("window-position", "(ii)", root_x, root_y);

            return GLib.Source.REMOVE;
        });

        return base.configure_event (event);
    }
}