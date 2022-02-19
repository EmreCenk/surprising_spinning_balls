// feel free to play around with these values
int number_of_balls = 1000;
float spacing_between_balls = 1;
int ball_radius = 12;
float spinning_speed_difference = 0.0001; // how much the spin speed should increase between each ball
String color_mode = "gradient"; // "gradient" or "alternating". if "gradient": colors of balls will be in a gradient. if "alternating": the colors will be alternating
String direction = "counterclockwise"; // "clockwise" or "counterclockwise"
color[] default_colors = {color(255, 0, 0), color(0, 255, 0), // the default color scheme if there is no gradient
                          //color(0, 0, 255), color(255, 255, 255)
                         }; 
boolean draw_circle_outline = false; // do you want processing to draw outlines on the circles? Spoiler: it looks way better without outlines


// random coefficients to multiply the balls' spin speeds by certain coefficients:
// The i'th coefficient is applied to every ball with index i, i+len(random_coefficients), i+2*len(random_coefficients), i+3*len(random_coefficients)...
// in other words, the i'th coefficient is applied to every ball with index k, where i%random_coefficients.length == k
float[] random_coefficients = {0.5}; // right now it's multiplying all spin speeds by 0.5, so it's not doing anything. Check out the examples below if you want to see some cooler values

// here are some more interesting random_coefficients values you could try (they get cooler the more you go down):
//float[] random_coefficients = {0.18, 0.19, 0.20, 0.21};
//float[] random_coefficients = {0.0, -0.002, 0.004, -0.006, 0.008, -0.01, 0.012, -0.014, 0.016, -0.018, 0.02, -0.022, 0.024, -0.026, 0.028, -0.03, 0.032, -0.034, 0.036, -0.038, }; 
//float[] random_coefficients = {0.4, -0.4};
//float[] random_coefficients = {0.4, -0.8};


// draws a bunch of lines that connect certain balls.
// WARNING: draw_weird_lines LOOKS VERY BAD FOR ANY random_coefficient CONFIGURATION EXCEPT random_coefficients = {K} WHERE K IS SOME CONSTANT
boolean draw_weird_lines = false; // I repeat: only turn on if random_coefficients = {0.5} or some other constant (I mean... you COULD turn it on whenever you like ... if you want your eyes to bleed)

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
    println("WARNING: '" + color_mode + "' is not a valid color mode. By default, the 'gradient' mode has been selected.\nPlease make sure the value for the 'color_mode' variable is valid.");
  }
  
  // generates the gradient of colors
  colors = new color[number_of_balls];
  int r = 0;
  int g = 0;
  int b = 0;
  int plus = 1; // what we will increment by
  for (int i = 0; i<number_of_balls; i++){
    if (0 <= r && r < 255) { 
      r+=plus;
    } else if (0 <= g && g < 255) {
      g+=plus;
    } else if (0 <= b && b < 255) {
      b+=plus;
    } else {
      plus *= -1; // we're at the boundary, we gotta reverse the direction
      r+=plus;
      g+=plus;
      b+=plus;
    };
    colors[i] = color(r, g, b);
  }
}
void generate_balls(){
  // generates a list of balls
  
  generate_colors(); // lets make sure all our colors our defined beforehand
  balls = new SpinningCircle[number_of_balls]; 
  float starting_point_x = (width/2) - (number_of_balls*spacing_between_balls/2);
  float starting_point_y = height/2;
  
  int spin_speed_coefficient; // will be used to control clockwise or counterclockwise
  if (direction == "counterclockwise") spin_speed_coefficient = -1;
  else if (direction == "clockwise") spin_speed_coefficient = 1;
  else{
    // invalid input, but I'll run the program anyways
    println("WARNING: '" + direction +"' cis not an option for direction. Direction must be 'clockwise' or 'counterclockwise'.\nBy default, the program has picked clockwise.");
    spin_speed_coefficient = 1;
  };
  
  for (int i = 0; i<number_of_balls; i++){
    balls[i] = new SpinningCircle(starting_point_x + spacing_between_balls * i, //x coordinate
                                  starting_point_y, //y coordinate
                                  ball_radius, // radius
                                  spin_speed_coefficient * (i + 1) * spinning_speed_difference * random_coefficients[i%random_coefficients.length], // the speed ball will spin at
                                  colors[i%colors.length]); // color
  }


}

void stroke_settings(){
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
    int spac = 500;
    for (int i = number_of_balls - 1; i > spac; i-=2){
      stroke(balls[i].ball_color);
      line(balls[i].x, balls[i].y, balls[i-spac].x, balls[i-spac].y);
    };
    stroke_settings();
  };
}

void mouseClicked(){
  //click on the screen to pause the animation
  if (screen_is_paused) loop();
  else noLoop();  
  screen_is_paused = !screen_is_paused;
  return;
}
void keyPressed(){

  if (screen_is_paused) return;
  
  //no need for else if since we returned
  if (key == 's' || key == 'S'){
    //press the S key to open slow motion
    float coefficient;
    float slow_motion_coef = spinning_speed_difference * number_of_balls * 100;
    
    if (in_slow_motion) coefficient = slow_motion_coef; // if we're in slow motion, that means we just multiplied with 1/slow_motion_coef. To simplify the 1/slow_motion_coef, we will multiply with slow_motion_coef
    else coefficient = 1/slow_motion_coef;
    for (int i = 0; i<number_of_balls; i++){
      balls[i].spin_speed *= coefficient;
    }
    in_slow_motion = !in_slow_motion;

  }
  
}
