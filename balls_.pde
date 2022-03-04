/*
An animation that spins a bunch of balls at different speeds (increasing unless specified otherwise)
press p to take a pictures
press s to toggle slow motion
click the screen to pause animation
There are some demo pictures under the output folder. 
If you don't feel like playing with a bunch of settings to discover the cool animations yourself, you can check out the output folder to see some interesting patterns.
*/ 


// feel free to play around with these values
int number_of_balls = 1000;
float spacing_between_balls = 1; // how spread out you want the balls to be 
int ball_radius = 12;
float spinning_speed_difference = 0.0001; // how much the spin speed should increase between each ball
String color_mode = "gradient"; // "gradient" or "alternating". if "gradient": colors of balls will be in a gradient. if "alternating": the colors will be alternating
float gradient_increment = 1.25*1000/float(number_of_balls); //gradient rate of change between balls (increase this for a sharper change in the gradient, decrease for smoother transition) 
// [right now I have a formula to find the optimal rate of change to include all colors, so I wouldn't change it if I were you. but if you were to change, the value should be 0 < X < 255]
String direction = "counterclockwise"; // "clockwise" or "counterclockwise"
color[] default_colors = {color(255, 0, 0), color(255, 255, 255), // the default color scheme if there is no gradient
                          //color(0, 0, 255), color(255, 255, 255) // you can add as many colors as you like
                         }; 
boolean draw_circle_outline = false; // do you want processing to draw outlines on the circles? Spoiler: it looks way better without outlines [this was mainly used to debug, it should be false if you want the balls to look good]


// random coefficients to multiply the balls' spin speeds by certain coefficients:
// The i'th coefficient is applied to every ball with index i, i+len(random_coefficients), i+2*len(random_coefficients), i+3*len(random_coefficients)...
// in other words, the i'th coefficient is applied to every ball with index k, where i%random_coefficients.length == k
float[] random_coefficients = {0.5}; // right now it's multiplying all spin speeds by 0.5, so it's not doing anything. Check out the examples below if you want to see some cooler values

// here are some more interesting random_coefficients values you could try (they get cooler the more you go down!):
// (if you haven't tried the following values, then you haven't properly experienced this program)
//float[] random_coefficients = {0.18, 0.19, 0.20, 0.21};
//float[] random_coefficients = {-0.002, 0.004, -0.006, 0.008, -0.01, 0.012, -0.014, 0.016, -0.018, 0.02, -0.022, 0.024, -0.026, 0.028, -0.03, 0.032, -0.034, 0.036, -0.038, }; 
//float[] random_coefficients = {0.4, -0.4};
//float[] random_coefficients = {0.2, -0.2, 0.25, -0.25};




boolean draw_weird_lines = false; // draws a bunch of lines that connect certain balls
// WARNING: draw_weird_lines does not look very good for certain random_coefficients configurations. Turning this on also causes a sharp decrease in framerate.
int line_skip_ball_number = 200; //how many balls should be between the line (a line will be drawn between the i'th ball and i+line_skip_ball_number'th ball)



//////////////////////////////////////////////////////////////
//don't play with anything from this line onward
color[] colors; //stores the colors of the balls (we don't actually have to store it because every instance of SpinningCircle keeps track of it's own color, but it's easier to have an array when generating the gradient)
boolean screen_is_paused = false; //stores whether the screen is paused;
boolean in_slow_motion = false; // stores whether the animation is in "slow motion" mode
SpinningCircle[] balls; // stores a list of balls. The custom SpinningCircle class is defined under the "SpinningCircleClass" file

void generate_colors(){

  // generates colors for balls
  if (color_mode.equals("alternating")){
    colors = default_colors;
    return;
  }
  if (!color_mode.equals("gradient")){
    // invalid input, but I'll run the program anyways
    println("WARNING: '" + color_mode + "' is not a valid color mode. color_mode must be 'gradient' or 'alternating'. By default, the 'gradient' mode has been selected.\nPlease make sure the value for the 'color_mode' variable is valid.");
  }
  
  // generates the gradient of colors
  colors = new color[number_of_balls];
  
  //r,g,b is what color the gradient will start at. (0,0,0) is perfect because the outermost balls barely move anyways, so it's better for them to be less visible
  float r = 0;
  float g = 0;
  float b = 0;
  for (int i = 0; i<number_of_balls; i++){ // loop throught, increase and decrease rgb values respectively to create a gradient
    if (0 <= r && r < 255) r+=gradient_increment;
    else if (0 <= g && g < 255) g+=gradient_increment;
    else if (0 <= b && b < 255) b+=gradient_increment;
    else {
      gradient_increment *= -1; // we're at the boundary, we gotta reverse the direction we're in crementing in
      r+=gradient_increment;
      g+=gradient_increment;
      b+=gradient_increment;
    };
    colors[i] = color(r, g, b);
  }
}
void generate_balls(){
  // generates a list of balls
  
  generate_colors(); // lets make sure all our colors our defined beforehand. All stored colors are automatically dumped into the colors variable
  balls = new SpinningCircle[number_of_balls]; 
  
  // the coordinates of the first ball:
  float starting_point_x = (width/2) - (number_of_balls*spacing_between_balls/2);
  float starting_point_y = height/2;
  
  int spin_direction_coefficient; // will be used to control clockwise or counterclockwise
  if (direction == "counterclockwise") spin_direction_coefficient = -1;
  else if (direction == "clockwise") spin_direction_coefficient = 1;
  else{
    // invalid input, but I'll run the program anyways
    println("WARNING: '" + direction +"' is not an option for direction. Direction must be 'clockwise' or 'counterclockwise'.\nBy default, the program has picked clockwise.");
    spin_direction_coefficient = 1;
  };
  
  for (int i = 0; i<number_of_balls; i++){ // generates balls
    balls[i] = new SpinningCircle(starting_point_x + spacing_between_balls * i, //x coordinate
                                  starting_point_y, //y coordinate
                                  ball_radius, // radius
                                  spin_direction_coefficient * (i + 1) * spinning_speed_difference * random_coefficients[i%random_coefficients.length], // the speed ball will spin at
                                  colors[i%colors.length]); // color
  }


}

void stroke_settings(){
  // adjusts stroke settings
  if (draw_circle_outline) stroke(255);
  else noStroke();  
}
void setup(){
  frameRate(75);
  stroke_settings();
  fill(0);

  size(1400, 1000);
  generate_balls(); // getting our balls ready
}

void draw(){
  background(0);
  for (int i = 0; i < number_of_balls; i++){
    // all we have to do is loop through the balls, update their positions, then display them on the screen.
    balls[i].update();
    balls[i].display();
  };
  
  if (draw_weird_lines){
    // draw a line between ball at index i and ball at index i + line_skip_ball_number 
    for (int i = 0; i < balls.length - line_skip_ball_number; i+=1){
      stroke(balls[i].ball_color);
      line(balls[i].x, balls[i].y, balls[(i+line_skip_ball_number)%balls.length].x, balls[(i+line_skip_ball_number)%balls.length].y);
    };
    stroke_settings(); // if the user wants no outline on the balls, we have to reset that setting (since we have stroke(balls[i].ball_color))
  };
  
  // Drawing lines drops the framerate so I used these when trying to improve efficiency:
  //textSize(40);
  //text("fps: " + str(round(frameRate)), 100, 100);
}

void mouseClicked(){
  //click on the screen to pause the animation
  if (screen_is_paused) loop();
  else noLoop();  
  screen_is_paused = !screen_is_paused;
}
void keyPressed(){
  // press 's' to toggle slow motion
  // press 'p' to take a picture
  if (key == 's' || key == 'S'){
     if (screen_is_paused) return;
    //toggling slow motion
    float coefficient;
    float slow_motion_coef = spinning_speed_difference * number_of_balls * 100; // by what coefficient we will slow down the balls by (the formula is there just to scale the coefficient according to the number of balls)
    
    if (in_slow_motion) coefficient = slow_motion_coef; // if we're in slow motion, that means we just multiplied with 1/slow_motion_coef. To cancel the effect of 1/slow_motion_coef, we will multiply with slow_motion_coef
    else coefficient = 1/slow_motion_coef; // to open slow motion, we will just divide every ball's spin speed by the coefficient
    
    for (int i = 0; i<number_of_balls; i++) balls[i].spin_speed *= coefficient;
    
    in_slow_motion = !in_slow_motion;
    return;
  }
  
  if (key == 'p' || key == 'P'){
    // press the p key to take a picture
    saveFrame("output/cool_picture####.png"); // all pictures are saved under the output folder
    println("Took picture!"); 
  }
  
}
