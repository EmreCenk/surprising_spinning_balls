
// feel free to play around with these values
int number_of_balls = 100;
int spacing_between_balls = 3;
int ball_radius = 10;
float spinning_speed_difference = 0.0005;
color[] colors = { color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(255, 255, 255) };

//don't play with anything from this line onward


boolean screen_is_paused = false; //stores whether the screen is paused;
boolean in_slow_motion = false; // stores whether the animation is in "slow motion" mode
SpinningCircle[] balls;

void generate_balls(){
  balls = new SpinningCircle[number_of_balls];
  float starting_point_x = (width/2) - (number_of_balls*spacing_between_balls/2);
  float starting_point_y = height/2;
  for (int i = 0; i<number_of_balls; i++){
    balls[i] = new SpinningCircle(starting_point_x + spacing_between_balls * i,
                                  starting_point_y,
                                  ball_radius,
                                  (i + 1)*spinning_speed_difference * pow(-1, i),
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
  size(1000, 1000);
  generate_balls();
}

void draw(){
  background(0);
  for (int i = 0; i < number_of_balls; i++){
    balls[i].update();
    balls[i].display();
  };

}
void keyPressed(){
  if (key == 'p'){
    //pause screen
    if (screen_is_paused)loop();
    else noLoop();  
    screen_is_paused = !screen_is_paused;
    return;
  }
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
