
class SpinningCircle{
  // Defines a SpinningCircle class that has the utility methods neccesary to keep track of balls and spin them
  
  float x, y, r, spin_speed; // x, y coordinates, the radius and how fast the ball will spin
  float centerx, centery; // what the ball will rotate around
  float distance_from_pivot; // distance from (centerx, centery) to (x, y)
  float current_angle; // current angle the ball is at relative to (centerx, centery)
  color ball_color;
  SpinningCircle(float starting_x,
                 float starting_y,
                 float radius,
                 float spin_speed_,
                 color color_of_ball){
    
    // setting the ball's values to what was defined:               
    x = starting_x;
    y = starting_y;
    r = radius;
    spin_speed = spin_speed_;
    ball_color = color_of_ball;
    
    // non input ball values:
    
    // just in case I want to rotate different balls around different locations, I'm implementing a dynamic centerx and centery
    centerx = width / 2;
    centery = height / 2;
    
    distance_from_pivot = dist(x, y, centerx, centery);
    current_angle = atan((y-centery)/(x-centerx));

  }
  
  void display(){
    fill(ball_color);
    circle(x, y, r);
  }
  void update(){
    // spin the ball at whatever spin speed we've defined
    // maybe there's even a utility function for this? 
    current_angle += spin_speed;
    current_angle %= 2*PI;
    x = centerx + distance_from_pivot * cos(current_angle);
    y = centery + distance_from_pivot * sin(current_angle);
  }
}
