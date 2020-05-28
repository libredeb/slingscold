/* Copyright 2020 Juan Lozano <libredeb@gmail.com>
*
* This file is part of Slingscold.
*
* Slingscold is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Slingscold is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Slingscold. If not, see http://www.gnu.org/licenses/.
*/
namespace Slingscold.Frontend {

    public class Searchbar : Gtk.Box {
        
        // Constants
        const int WIDTH = 240; // Search bar width
        const int HEIGHT = 26; // Search bar height
        
        // Signals
        public signal void changed ();
        
        public string text {
            owned get {
                string current_text = this.buffer.text;
                return (current_text == this.hint_string && this.is_hinted) ? "" : current_text;
            }
            set {
                this.buffer.text = value;
                if (this.buffer.text == "") {
                    this.hint ();
                } else {
                    this.reset_font ();
                    this.label.label = this.buffer.text; 
                    this.label.select_region (-1, -1);
                    this.clear_icon.visible = true;
                }
            }
        }
        
        private Gtk.TextBuffer buffer;
        public Gtk.Label label;
        public Gtk.Image search_icon;
        private Gtk.Image clear_icon;
        public string hint_string;

        // protects against bug where get_text() will return "" if the user 
        // happens to type in the hint string
        private bool is_hinted = true;
        

        public Searchbar (string hint) {
            this.hint_string = hint;
            this.buffer = new Gtk.TextBuffer (null);
            this.buffer.text = this.hint_string;
            
            // HBox properties

            this.set_homogeneous (false);
            this.set_can_focus (false);
            this.set_size_request (WIDTH, HEIGHT);
        
            // Wrapper 
            // space between the icon and the phrase search
            var wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 3);
            this.add (wrapper);
            
            // Pack edit-find-symbolic icon
            var search_icon_wrapper = new Gtk.EventBox ();
            search_icon_wrapper.set_visible_window (false);
            this.search_icon = new Gtk.Image.from_icon_name("edit-find-symbolic", Gtk.IconSize.MENU); //search icon
            search_icon_wrapper.add (this.search_icon);
            search_icon_wrapper.border_width = 4;
            search_icon_wrapper.button_release_event.connect ( () => {return true;});
            wrapper.pack_start (search_icon_wrapper, false, true, 3);
            
            // Label properties
            this.label = new Gtk.Label (this.buffer.text);
            this.label.set_ellipsize (Pango.EllipsizeMode.START);
            this.label.set_alignment(0.0f, 0.5f);
            this.label.selectable = true;
            this.label.can_focus = false;
            this.label.set_single_line_mode (true);
            wrapper.pack_start (this.label, true, true, 0);
            
            // Clear icon
            var clear_icon_wrapper = new Gtk.EventBox ();
            clear_icon_wrapper.set_visible_window (false);
            clear_icon_wrapper.border_width = 4;
            this.clear_icon = new Gtk.Image.from_icon_name("edit-clear-symbolic", Gtk.IconSize.MENU);
            
            clear_icon_wrapper.add (this.clear_icon);
            clear_icon_wrapper.button_release_event.connect ( () => { this.hint (); return true; });
            clear_icon_wrapper.set_hexpand (true);
            clear_icon_wrapper.set_halign (Gtk.Align.END);
            wrapper.pack_end (clear_icon_wrapper, false, true, 3);
            
            // Connect signals and callbacks
            this.buffer.changed.connect (on_changed);
            this.draw.connect (this.draw_background);
            this.realize.connect (() => {
                this.hint (); // hint it
            });
        
        }
        
        public void hint () {
            this.buffer.text = "";
            this.label.label = this.hint_string;
            this.grey_out ();
            this.clear_icon.visible = false;
        }

        public void unhint () {
            this.text = "";
            this.reset_font ();
        }
        
        
        private void grey_out () {
            var color = Gdk.RGBA ();
            color.parse ("#a0a0a0");
            this.label.override_color (Gtk.StateFlags.NORMAL, color);
            this.label.override_font (Pango.FontDescription.from_string ("italic"));
            this.is_hinted = true;
        }
        
        private void reset_font () {
        
            var color = Gdk.RGBA ();
            color.parse ("#FFFFFF");
            this.label.override_color (Gtk.StateFlags.NORMAL, color);
            this.label.override_font (Pango.FontDescription.from_string ("normal"));
            this.is_hinted = false;
        
        }
        
        private void on_changed () {
            // Send changed signal
            this.changed ();
        }
        
        private bool draw_background (Gtk.Widget widget, Cairo.Context ctx) {
            Gtk.Allocation size;
            widget.get_allocation (out size);
            var context = Gdk.cairo_create (widget.get_window ());
            
            // Draw bottom white border
            Slingscold.Frontend.Utilities.draw_rounded_rectangle (context, 6, -0.5, size);
            var linear_stroke = new Cairo.Pattern.linear(size.x, size.y, size.x, size.y + size.height);
            linear_stroke.add_color_stop_rgba (0.0,  1.0, 1.0, 1.0, 0.0);
            linear_stroke.add_color_stop_rgba (0.85,  1.0, 1.0, 1.0, 0.0);
            linear_stroke.add_color_stop_rgba (1.0,  1.0, 1.0, 1.0, 0.4);
            context.set_source (linear_stroke);
            context.fill ();
            
            Slingscold.Frontend.Utilities.draw_rounded_rectangle (context, 6, 0.5, size);
            
            // Draw background gradient
            var linear_fill = new Cairo.Pattern.linear(size.x, size.y, size.x, size.y + size.height);
            linear_fill.add_color_stop_rgb(0.0,  0.08, 0.1, 0.12);
            linear_fill.add_color_stop_rgb(0.25, 0.08, 0.1, 0.12);
            linear_fill.add_color_stop_rgb(1.0,  0.08, 0.1, 0.12);
            context.set_source (linear_fill);
            context.fill_preserve ();
            
            // Draw outside black stroke
            context.set_source_rgba (0.1, 0.1, 0.1, 1.0);
            context.set_line_width (1.0);
            context.stroke ();
            
            // Draw inner stroke
            // Draw bottom white border
            Slingscold.Frontend.Utilities.draw_rounded_rectangle (context, 6, 1.5, size);
            context.set_source_rgba (0.0, 0.0, 0.0, 0.2);
            context.stroke ();
            
            return false;
        }
        
    }
}
