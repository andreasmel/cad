/*
todo:

Q how well will bearingmount print with the overhang? 
A overhang is ok, but top is too fragile. How sort?

get rid of at least 1 captive nut on the magnet holder? maybe best to keep both in case one gets clogged

*/
$fa=5;
$fs=1;
include <tab_creator.scad>;
draw_magnets=true;
draw_ally=true;
//for tab creation
min_thickness=2;
clearance=1.02;
bolt_radius=1.5;
bolt_length=12;
winding_bolt_length=10;
nut_width=6;
nut_height=2.5;
wall_thickness=3.25;
num_blades=3;
blade_rake=20;
bush_length = min_thickness*2+bolt_radius*2;
bearing_diameter=22;
bearing_sleeve_r=bearing_diameter/2+min_thickness;
echo( str("bearing sleeve d=" , bearing_sleeve_r*2));
bearing_inner_sleeve_r=11/2;
bearing_height=8;
shaft_diameter=8;
magnet_length=25.2;
magnet_width=10;
magnet_height=3;
width=50;
height=50;
length=50;
tail_length=length;
tail_bolt_hole_length = tail_length/2;
tail_rod_length=4*length;

magnet_holder_length=length-wall_thickness*2;
magnet_spacing=shaft_diameter+wall_thickness+2*magnet_height; //how far the magnets should be from the shaft
magnet_holder_r = 12; //eyeballed

winding_clearance=1; //eyeballed
winding_height=(width - magnet_holder_r*2 - winding_clearance )/ 2;
winding_width=width/2;
winding_length=magnet_length;

module box_lid(width,length)
{
    make_tab_slots([width,length,wall_thickness],[1,0,0],wall_thickness,bolt_radius)
    difference()
    {
        cube([length,width,wall_thickness],center=true);
        rotate([90,90,0])
            tail_bolt_holes(tail_bolt_hole_length);
    }
}
module box_base(width,length)
{
    make_tab_slots([width,length,wall_thickness],[1,0,0],wall_thickness,bolt_radius)
    difference()
    {
        cube([length,width,wall_thickness],center=true);
        //1 bottom bearing
        cylinder(h=length*2,r=bearing_sleeve_r*clearance,center=true);
    }
}
module box_front(width,height)
{
    color("red",1)
    make_tab_slots([height,width,wall_thickness],[0,1,0],wall_thickness,bolt_radius)
    make_tabs([height,width,wall_thickness],[1,0,0],wall_thickness,bolt_radius,bolt_length,nut_width,nut_height)
    difference()
    {
        cube([height,width,wall_thickness],center=true);
        cylinder(h=length*2,r=bearing_sleeve_r*clearance,center=true);
    }
}

module box_side(length,height)
{
    color("yellow")
    make_tabs([length,height,wall_thickness],[1,0,0],wall_thickness,bolt_radius,bolt_length,nut_width,nut_height)
        difference()
        {
            cube([length,height,wall_thickness],center=true);
            horizontal_tab_slots([winding_width,winding_length*0.7,wall_thickness],wall_thickness,bolt_radius);
        }

}

//TODO: needs holes for the wires to come out, and for a motor shaft to assist winding
//height refers to the total height of the winding post
//length referes to total length of winding post (the widest part of the winding shoudler, not the length of the body of the winding post
module winding(width,length,height)
{
    //the coils go round this
    rise=2;
    make_tabs([height,length*0.7,wall_thickness],[1,0,0],wall_thickness,bolt_radius,winding_bolt_length,nut_width,nut_height,1)
    union()
    {
        cube([height,length*0.7,wall_thickness],center=true);
        translate([-height/2+rise,0,-wall_thickness/2])
            rotate([0,0,90])
                winding_shoulder(length,rise);
        translate([height/2+rise/2-winding_bolt_length+rise,0,-wall_thickness/2])
            rotate([0,0,-90])
                winding_shoulder(length,rise);
    }
}
module winding_shoulder(length,rise)
{
    bottom_length=length*0.7;
    top_length=length*0.9;

    linear_extrude(height=wall_thickness)
      polygon([[0,0],[bottom_length/2,0],[top_length/2,rise],[-top_length/2,rise],[-bottom_length/2,0],[0,0]]);
}

module bush_captive_nut(bush_length,spacer=false)
{
	difference()
	{
	union()
	{
        translate([0,0,bush_length/2])
            cylinder(r=magnet_holder_r,h=bush_length,center=true);
	if(spacer)
	{
	translate([0,0,bush_length])
		cylinder(r=bearing_inner_sleeve_r,h=1);
	}
	}
        translate([0,0,bush_length/2])
            cylinder(r=shaft_diameter/2,h=bush_length*2,center=true);
        //slot for a captive nut
        translate([(magnet_holder_r+shaft_diameter/2)/2-nut_height/2+1,0,bush_length/2])
            rotate([0,90,0])
                cube([bush_length*2,nut_width,nut_height],center=true);
        //hole for a bolt
        translate([magnet_holder_r/2+0.1,0,bush_length/2])
            rotate([0,90,0])
                cylinder(r=bolt_radius,h=magnet_holder_r,$fn=20,center=true);
	}

}
module magnet_holder()
{
    difference()
    {
	bush_captive_nut(bush_length);
        //magnet holes
        translate([0,0,magnet_length/2+bush_length-min_thickness])
            rotate([0,90,0])
                magnets();
    }
}
module magnets()
{
    color("blue")
    rotate([90,0,0])
    {
        translate([0,0,magnet_spacing/2-magnet_height/2])
              cube([magnet_length,magnet_width,magnet_height],center=true);
        translate([0,0,-magnet_spacing/2+magnet_height/2])
              cube([magnet_length,magnet_width,magnet_height],center=true);
    }
    }

module tail()
{

}
module blade_holder()
{
       bush_captive_nut(bush_length,spacer=true); 
        union()
        {
            for(i=[0:num_blades-1])
            {
                rotate([0,0,i*360/num_blades+40])
                    translate([0,0,0])
                        blade_mount();
            }
        }
}

module blade_mount()
{
    base_thickness=2;
    blade_holder_length=25;
    blade_holder_width=10;
    holder_height=tan(blade_rake)*blade_holder_width;
    //echo(holder_height);
            difference()
            {
            translate([-blade_holder_width/2,-8,0])
            rotate([90,0,0])
            {
                linear_extrude(height=blade_holder_length)
                polygon([[0,0],[blade_holder_width,0],[blade_holder_width,holder_height+base_thickness],[0,base_thickness]]);
                }
        
        //bolt holes
        for(i=[0:1])
        {
            translate([2,-17-i*10,0])
                rotate([0,-blade_rake,0])
                    cylinder(r=1.5,h=50,center=true,$fn=12);
        }
    }


}

//something to mount the tail onto the boom
module tail_adapter()
{
    length=tail_length/2;
    adapter_height=shaft_diameter-0.5+min_thickness; //subtract 0.5 to make a tight fit when bolted

    translate([0,0,adapter_height/2])
    rotate([0,-90,0])
    difference()
    {
        cube([adapter_height,length,shaft_diameter*2+bolt_radius*2],center=true);
        translate([min_thickness/2,0,0])
            rotate([90,0,0])
                cylinder(r=shaft_diameter/2,h=length*2,center=true);
        translate([shaft_diameter/2+min_thickness,0,0])
        cube([adapter_height,length*2,shaft_diameter],center=true);
        //bolt holes
        tail_bolt_holes(length);

    }

}
module tail_bolt_holes(length)
{
        translate([0,length/2-bolt_radius*2,shaft_diameter-bolt_radius])
            tail_bolt_hole();
        translate([0,-length/2+bolt_radius*2,shaft_diameter-bolt_radius])
            tail_bolt_hole();
        translate([0,length/2-bolt_radius*2,-shaft_diameter+bolt_radius])
            tail_bolt_hole();
        translate([0,-length/2+bolt_radius*2,-shaft_diameter+bolt_radius])
            tail_bolt_hole();
}
module tail_fin()
{
    length=tail_length/2;
    difference()
    {
        cube([tail_length,tail_length,wall_thickness],center=true);
        rotate([0,90,90])
            tail_bolt_holes(length);
    }
}
module tail_bolt_hole()
{
    rotate([0,90,0])
        cylinder(r=bolt_radius,h=shaft_diameter*2,center=true,$fn=10);
}

module bearing()
{
    difference()
    {
        cylinder(r=bearing_diameter/2,h=bearing_height,center=true);
        cylinder(r=shaft_diameter/2,h=bearing_height*2,center=true);
    }
}

module bearing_mount()
{
    difference()
    {
      union()
        {
          translate([0,0,bearing_height/4])
          //1mm overhang for rim
            cylinder(r=bearing_diameter/2+min_thickness+1,h=min_thickness/2,center=true);
          //the sleeve
          cylinder(r=bearing_sleeve_r,h=bearing_height/2,center=true);
        }
        translate([0,0,bearing_height/2])
        cylinder(r=bearing_diameter/2,h=bearing_height,center=true);
        cylinder(r=shaft_diameter,h=bearing_height,center=true);
    }
}

module end_stop()
{
	bush_captive_nut(bush_length,spacer=true);
}
module show_all()
{
  color("green")
  echo($t*360);
  rotate([$t*360,0,0])
  {

  magnets();
  color("blue")
      translate([length/2+15,0,0])
          rotate([0,90,180])
              blade_holder();
    //the 3 bearings
    color("green")
    {
      translate([length/2+bearing_height/2,0,0])
          rotate([0,90,180])
            bearing();
      translate([-length/2-bearing_height/2,0,0])
          rotate([0,90,180])
            bearing();
      translate([0,0,-height/2-bearing_height/2])
          rotate([0,0,0])
            bearing();
            }
     //bearing mounts/sleeves
      translate([length/2+bearing_height/2,0,0])
          rotate([0,90,0])
            bearing_mount();
      translate([-length/2-bearing_height/2,0,0])
          rotate([0,90,180])
            bearing_mount();
      translate([0,0,-height/2-bearing_height/2])
          rotate([0,180,0])
            bearing_mount();

  //show the ally rotor tube
  if(draw_ally)
    color("red")
        rotate([0,90,0])
            cylinder(r=shaft_diameter/2,h=length*1.8,center=true);
  //show the ally tail tube
  if(draw_ally)
    color("red")
        translate([-tail_rod_length/2+length/2+wall_thickness*2,0,+height/2+shaft_diameter/2+wall_thickness])
        rotate([0,90,0])
            cylinder(r=shaft_diameter/2,h=tail_rod_length,center=true);

    //tail adapter
    color("blue")
    translate([-tail_rod_length+tail_length/4+length/2+wall_thickness*2,-shaft_diameter,height/2+shaft_diameter])
        rotate([0,90,90])
            tail_adapter();
    //fin
    translate([-tail_rod_length+tail_length/4+length/2+wall_thickness*2,+shaft_diameter/2,+height/2+shaft_diameter])
    rotate([90,0,0])
    tail_fin();

  //translate([-100,0,0])
  translate([-bush_length-magnet_length/2+min_thickness,0,0])
  rotate([90,90,90])
      magnet_holder();
  translate([+bush_length+magnet_length/2-min_thickness,0,0])
  rotate([-90,90,90])
      magnet_holder();
  }

  //static stuff
  
  //lid
  if(draw_lid)
  {
      translate([0,0,+height/2+wall_thickness/2])
          box_lid(width,length);
        color("blue")

    //lid tail adapter
//        translate([-tail_rod_length/2+length/2+wall_thickness*2,-width/2+shaft_diameter+wall_thickness,+height/2+shaft_diameter/2+wall_thickness])
        translate([0,0,+height/2+shaft_diameter+wall_thickness+min_thickness])
            rotate([0,180,90])
                tail_adapter();
  }
   //base
  translate([0,0,-height/2-wall_thickness/2])
      box_base(width,length);
    //front and back
    translate([-length/2-wall_thickness/2,0,0])
        rotate([0,90,0])
            box_front(width,height);
    translate([+length/2+wall_thickness/2,0,0])
        rotate([0,90,0])
            box_front(width,height);
    //sides
    translate([0,+width/2+wall_thickness/2,0])
        rotate([90,0,0])
            box_side(length,height);
    translate([0,-width/2-wall_thickness/2,0])
        rotate([90,0,0])
            box_side(length,height);

  color("grey")
   {
       translate([0,width/2-winding_height/2,0])
          rotate([0,0,90])
              winding(winding_width,winding_length,winding_height);
       translate([0,-width/2+winding_height/2,0])
          rotate([0,0,270])
              winding(winding_width,winding_length,winding_height);
  }
//end stop
  translate([-length/2-2*bush_length,0,0])
  rotate([-90,180,-90])
	end_stop();

}

//build everything in it's place
*show_all();
//draw_lid=true;
*end_stop();
*bearing_mount();
//or for printing, uncomment the part you want
*magnet_holder();
*blade_holder();
//winding mount
*projection(cut=true)
  winding(width/2,magnet_length,winding_height);

*projection(cut=true)
  box_base(width,length,true);

//test hole
*projection(cut=true)
        cylinder(h=length*2,r=bearing_sleeve_r*clearance,center=true);

projection(cut=true)
  box_front(width,height);

*projection(cut=true)
  box_side(width,height);

*box_lid(width,length);
*tail_adapter();

//test hole for the spring fitting
*difference()
{
cube([40,40,wall_thickness],center=true);
winding_base(width/2,magnet_length,wall_thickness*2);
}
