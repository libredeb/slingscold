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
namespace Widgets {

    public class CompositedWindow : Gtk.Window {
    
        construct {
        
            //Window properties
            this.set_skip_taskbar_hint (true);
            this.set_decorated (false); // no window decoration
            this.set_app_paintable (true);
            this.set_name ("mainwindow");
            this.set_visual (this.get_screen().get_rgba_visual ());
            
            //this.set_default_colormap (this.get_screen ().get_rgba_colormap () ?? this.get_screen ().get_rgb_colormap ());
            
            this.draw.connect (clear_background);
            this.realize.connect (() => {
                // transparent background
                //var color = Gdk.RGBA ();
                //color.parse ("#a0a0a0");
                //this.override_background_color(Gtk.StateFlags.NORMAL, color);
            });
        
        }
        
        public bool clear_background (Gtk.Widget widget, Cairo.Context ctx) {

            ctx.set_operator (Cairo.Operator.CLEAR);
            ctx.paint();
            
            return false;
        }
    
    }
    
}
