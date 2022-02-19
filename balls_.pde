// feel free to play around with these values
int number_of_balls = 1000;
int spacing_between_balls = 1;
int ball_radius = 10;
float spinning_speed_difference = 0.0001;
String color_mode = "gradient"; // "gradient" or "alternating". if "gradient": colors of balls will be in a gradient. if "alternating": the colors will be alternating
String direction = "counterclockwise"; // "clockwise" or "counterclockwise"
color[] default_colors = {color(255, 0, 0),
                          color(0, 255, 0),
                          //color(0, 0, 255),
                          //color(255, 255, 255)
                          }; // the default color scheme if there is no gradient


// random coefficients to multiply the balls' spin speeds by certain coefficients:
// The i'th coefficient is applied to every ball with index i, i+len(random_coefficients), i+2*len(random_coefficients), i+3*len(random_coefficients)...
// in other words, the i'th coefficient is applied to every ball with index k, where k%len(random_coefficients) == i
//float[] random_coefficients = {0.5}; // right now it's multiplying all spin speeds by 0.5, so it's not doing anything. Check out the examples below if you want to see some cooler values

// here are some more interesting random_coefficients values you could try (they get cooler the more you go down):
//float[] random_coefficients = {0.18, 0.19, 0.20, 0.21};
//float[] random_coefficients = {0.0, -0.002, 0.004, -0.006, 0.008, -0.01, 0.012, -0.014, 0.016, -0.018, 0.02, -0.022, 0.024, -0.026, 0.028, -0.03, 0.032, -0.034, 0.036, -0.038, };
//float[] random_coefficients = {0.4, -0.4};
//float[] random_coefficients = {0.4, -0.8};


//don't play with anything from this line onward
color[] colors;
boolean screen_is_paused = false; //stores whether the screen is paused;
boolean in_slow_motion = false; // stores whether the animation is in "slow motion" mode
SpinningCircle[] balls; // stores a list of balls. The custom SpinningCircle class is defined later in the code


void generate_colors(){
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
  int plus = 1;
  for (int i = 0; i<number_of_balls; i++){
    if (0 <= r && r < 255) { 
      r+=plus;
    } else if (0 <= g && g < 255) {
      g+=plus;
    } else if (0 <= b && b < 255) {
      b+=plus;
    } else {
      plus *= -1;
      r+=plus;
      g+=plus;
      b+=plus;
    };
    colors[i] = color(r, g, b);
  }
}
void generate_balls(){
  generate_colors();
  balls = new SpinningCircle[number_of_balls];
  float starting_point_x = (width/2) - (number_of_balls*spacing_between_balls/2);
  float starting_point_y = height/2;
  
  int spin_speed_coefficient; // will be used to control clockwise or counterclockwise
  if (direction == "counterclockwise") spin_speed_coefficient = -1;
  else if (direction == "clockwise") spin_speed_coefficient = 1;
  else{
    println("'" + direction +"' cis not an option for direction. Direction must be 'clockwise' or 'counterclockwise'.\nBy default, the program has picked clockwise.");
    spin_speed_coefficient = 1;
  };
  
  for (int i = 0; i<number_of_balls; i++){
    balls[i] = new SpinningCircle(starting_point_x + spacing_between_balls * i,
                                  starting_point_y,
                                  ball_radius,
                                  spin_speed_coefficient * (i + 1) * spinning_speed_difference * random_coefficients[i%random_coefficients.length],
                                  colors[i%colors.length]);
  }
  //println(starting_point_x);
  //println(starting_point_y);

  //for (int i = 0; i<number_of_balls; i++)
  //  println(balls[i].x, balls[i].y);

}
void setup(){
  fill(0);
  stroke(255);
  //println("started progam");
  size(1400, 1000);
  generate_balls();

}

void draw(){
  background(0);
  for (int i = 0; i < number_of_balls; i++){
    balls[i].update();
    balls[i].display();
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
  if (key == 's'){
    //slow motion
    float coefficient;
    float slow_motion_coef = spinning_speed_difference * number_of_balls * 100;
    println(slow_motion_coef);
    if (in_slow_motion) coefficient = slow_motion_coef;
    else coefficient = 1/slow_motion_coef;
    for (int i = 0; i<number_of_balls; i++){
      balls[i].spin_speed *= coefficient;
    }
     in_slow_motion = !in_slow_motion;

  }
  
}

class SpinningCircle{
  
  float x, y, r, spin_speed; // x, y coordinates, the radius and how fast the ball will spin
  float centerx, centery; // what the ball will rotate around
  float distance_from_pivot;
  float current_angle; // current angle the ball is at
  color ball_color;
  SpinningCircle(float starting_x,
                 float starting_y,
                 float radius,
                 float spin_speed_,
                 color color_of_ball){
    x = starting_x;
    y = starting_y;
    r = radius;
    spin_speed = spin_speed_;
    ball_color = color_of_ball;
    centerx = width / 2;
    centery = height / 2;
    
    
    //to avoid division by 0 errors we have to consider these edge cases
    if (x==centerx)distance_from_pivot = abs(y - centery);
    else if (centery == y) distance_from_pivot = abs(x - centerx);
    else distance_from_pivot = dist(x, y, centerx, centery);
    current_angle = atan((y-centery)/(x-centerx));

  }
  
  void display(){
    circle(x, y, r);
  }
  void update(){
    fill(ball_color);
    current_angle += spin_speed;
    current_angle %= 2*PI;
    x = centerx + distance_from_pivot * cos(current_angle);
    y = centery + distance_from_pivot * sin(current_angle);
  }
}
