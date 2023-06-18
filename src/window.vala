/* window.vala
 *
 * Copyright 2023 Pedro Miguel
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Editordetexto {
    public class Window : Adw.ApplicationWindow {
        private Gtk.TextView textview;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0){
                vexpand = true,
                css_classes = {"white-bg"}
            };
            //header bar
            var headerbar = new Adw.HeaderBar ();
            content.append (headerbar);

            //open button
            var open_button = new Gtk.Button.with_label ("Open");
            open_button.clicked.connect (on_open);
            headerbar.pack_start (open_button);

            //tab button
            var tab_button = new Gtk.Button.from_icon_name ("tab-new-symbolic");
            headerbar.pack_start (tab_button);

            //menu button
            var menu_button = new Gtk.Button.from_icon_name ("open-menu-symbolic");
            headerbar.pack_end (menu_button);

            //save button
            var save_button = new Gtk.Button.from_icon_name ("document-save-symbolic");
            headerbar.pack_end (save_button);

            Gtk.ScrolledWindow ScrolledWindow = new Gtk.ScrolledWindow ();
            //text view
            textview = new Gtk.TextView () {
                vexpand = true,
                margin_top = 10,
                margin_bottom = 0,
                margin_start = 10,
                margin_end = 10
            };
            ScrolledWindow.child = textview;
            content.append (ScrolledWindow);

            this.set_content (content);
        }

        private void on_open () {
            var dialog = new Gtk.FileDialog ();
            dialog.title = "Open file";
            dialog.modal = true;

            dialog.open.begin (this, null, (obj, response) => {
              try {
                var file = dialog.open.end (response);

                if (file == null) {
                  debug ("No file selected, or no path available");
                  return;
                }

                print("Selected file: %s\n".printf (file.get_path()) );
                import_file.begin (file.get_path ());

              } catch (Error error) {
                switch (error.code) {
                  case Gtk.DialogError.CANCELLED:
                  case Gtk.DialogError.DISMISSED:
                    print ("Dismissed opening file: %s", error.message);
                    break;
                  case Gtk.DialogError.FAILED:
                  default:
                    print ("Could not open file: %s", error.message);
                    break;
                }
              }
            });
        }

        private async void import_file (string file_path) {
            string text;

            try {
                GLib.FileUtils.get_contents (file_path, out text);
            } catch (GLib.FileError error) {
                print(error.message);
                warning (error.message);
            };

            textview.buffer.text = text;
        }
    }
}
