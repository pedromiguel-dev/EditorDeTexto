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
        public Adw.HeaderBar headerbar;

        private string _file_name = "Editor de Texto";
        private string _file_path;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0){
                vexpand = true,
                css_classes = {"white-bg"}
            };
            //header bar
            headerbar = new Adw.HeaderBar ();
            headerbar.set_title_widget (new Adw.WindowTitle (_file_name, _file_path));
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
            save_button.clicked.connect (on_save);
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

        private void on_save () {
            var text_buffer = this.textview.buffer.text;

            if(this._file_path == null ) {
                save_contents.begin(text_buffer);
                return;
            };

            set_contents.begin(text_buffer);
        }
        private async void save_contents (string text_buffer){
            var dialog = new Gtk.FileDialog ();
            dialog.title = "Save new file";
            dialog.modal = true;

            dialog.save.begin (this, null, (obj, response) => {
              try {
                var file = dialog.save.end (response);

                if (file == null) {
                  debug ("No file selected, or no path available\n");
                  return;
                }

                print("Selected file: %s\n".printf (file.get_path()) );
                this._file_path = file.get_path();
                this._file_name = file.get_basename ();
                set_contents.begin(text_buffer);

              } catch (Error error) {
                switch (error.code) {
                  case Gtk.DialogError.CANCELLED:
                  case Gtk.DialogError.DISMISSED:
                    print ("Dismissed opening file: %s\n", error.message);
                    break;
                  case Gtk.DialogError.FAILED:
                  default:
                    print ("Could not open file: %s\n", error.message);
                    break;
                }
              }
            });
        }
        private async bool set_contents (string text_buffer){
            try{
                print("Saved\n");
                GLib.FileUtils.set_contents (this._file_path, text_buffer);
                update_headerbar();
                return true;
            } catch (GLib.FileError e){
                print(e.message);
                warning (e.message);
                return false;
            }
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
                this._file_path = file.get_path();
                this._file_name = file.get_basename ();
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
            this._file_path = file_path;
            string text;

            try {
                GLib.FileUtils.get_contents (file_path, out text);
                update_headerbar();
            } catch (GLib.FileError error) {
                print(error.message);
                warning (error.message);
            };

            textview.buffer.text = text;
        }

        private void update_headerbar () {
            this.headerbar.set_title_widget (new Adw.WindowTitle (_file_name, _file_path));
        }
    }
}
