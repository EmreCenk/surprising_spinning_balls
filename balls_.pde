
int screen_size = 600; //how many pixels you want the grid to be in total
int dimensions = 90; // how many cells you want on each side of grid. This must be divisible by screen_size
int player_num = 11;  // how many players per team
int ball_radius = 1; // ball radius in terms of cells
float wall_elasticity_coefficient = 0.1; // how bouncy the wall is (should be between 0-1)
float ball_mass = 10; // (kg) more mass means more friction force and ball is more difficult to move

int goalies_for_team1 = 20; // how many goalie's you want on team 1
int goalies_for_team2 = 1; // how many goalie's on team 2
float goalie_weakness_coeff = 1; // how much weaker should a goalie's kick be compared to a player? If this is greater than 1, goalies will be able to kick more powerfully than offence players

int[] team_1_vision_interval = {round(dimensions*0.1), round(dimensions*0.98)}; // speeds of team 2 will be in this interval
int[] team_2_vision_interval = {round(dimensions*0.1), round(dimensions*0.98)}; // speeds of team 2 will be in this interval

float[] team_1_speed_interval = {1, 4}; // speeds of team 1 will be in this interval
float[] team_2_speed_interval = {1, 4}; // speeds of team 2 will be in this interval

float[] team_1_kick_power_interval = {1, 2}; // kick powers of team 1 will be in this interval
float[] team_2_kick_power_interval = {1, 2}; // kick_powers of team 2 will be in this interval




float friction_coefficient = 0.003; // this changes the surface friction. 0.001 would be like ice and 0.003 would be like grass
/* 
Today I learned:
FrictionForce = FNormal * Mu
              = m * g * Mu
(in this case FNormal = m * g since the field is flat)
so why not implement it here?
*/


int team_1_goals = 0;
int team_2_goals = 0;
float friction = ball_mass * 9.81 * friction_coefficient;     
boolean debug = false;


Ball ball;
Cell[][] cells;
int[][] player_coordinates; // stores the coordinates of the players so we don't have to loop through every cell when trying to access players.
int collums_needed, players_per_collum;

void generate_player_stats(){
  //if (true) return;
  float a1, a2, c1, c2; 
  int side;
  int e1, e2;
  String player_type_;
  for (int[] c: player_coordinates){
    side = 1;
    player_type_ = "offence";
    if (cells[c[0]][c[1]].tag.equals("team1")){
      a1 = team_1_kick_power_interval[0];
      a2 = team_1_kick_power_interval[1];
      c1 = team_1_speed_interval[0];
      c2 = team_1_speed_interval[1];
      e1 = team_1_vision_interval[0];
      e2 = team_1_vision_interval[1];
      if (goalies_for_team1 > 0){
        player_type_ = "goalie";
        goalies_for_team1 -= 1;
        cells[c[0]][c[1]].cell_color = color(0, 0, 255);
        
        //goalie's can't kick as strong as offensive players:
        a1 = team_1_kick_power_interval[0] * goalie_weakness_coeff;
        a2 = team_1_kick_power_interval[1] * goalie_weakness_coeff;
      }

    }
    else{
      a1 = team_2_kick_power_interval[0];
      a2 = team_2_kick_power_interval[1];
      c1 = team_2_speed_interval[0];
      c2 = team_2_speed_interval[1];
      e1 = team_2_vision_interval[0];
      e2 = team_2_vision_interval[1];
      side *= -1;
      if (goalies_for_team2 > 0){

        // TODO: shift goalies to right or left
        player_type_ = "goalie";
        goalies_for_team2 -= 1;
        cells[c[0]][c[1]].cell_color = color(0, 0, 255);
        
        //goalie's can't kick as strong as offensive players:
        a1 = team_2_kick_power_interval[0] * goalie_weakness_coeff;
        a2 = team_2_kick_power_interval[1] * goalie_weakness_coeff;
      }
    }
    
    cells[c[0]][c[1]].player_type = player_type_;
    cells[c[0]][c[1]].kick_power = round(random(a1, a2));
    cells[c[0]][c[1]].speed = round(random(c1, c2));
    cells[c[0]][c[1]].vision = round(random(e1, e2));

    cells[c[0]][c[1]].side_to_score_on = side;
    //println(cells[c[0]][c[1]].kick_power, cells[c[0]][c[1]].speed);
    
  }

}
void player_decision(){

  //cells[player_coordinates[0][0]][player_coordinates[0][1]].player_type = "offence";
  //cells[player_coordinates[0][0]][player_coordinates[0][1]].speed = 1;
  //cells[player_coordinates[0][0]][player_coordinates[0][1]].kick_power = 3;
  
  //cells[player_coordinates[1][0]][player_coordinates[1][1]].player_type = "offence";
  //cells[player_coordinates[1][0]][player_coordinates[1][1]].speed = 2;
  //cells[player_coordinates[1][0]][player_coordinates[1][1]].kick_power = 4;
  //cells[player_coordinates[1][0]][player_coordinates[1][1]].side_to_score_on = -1;
  PVector new_coordinate;
  for (int[] c: player_coordinates){
    new_coordinate = cells[c[0]][c[1]].make_decision(c[0], c[1], ball, cells);
    c[0] = int(new_coordinate.x);
    c[1] = int(new_coordinate.y);
  }
  
}
void display_grid(){
  // displays grid
  // we can't make the player decisions here because a player's decision might update a cell that's already been looped through
  for (int i = 0; i < dimensions; i++){
    for (int j = 0; j < dimensions; j++){
      cells[i][j].display();
      //if (cells[i][j].tag.equals("ball")){println("ball", i, j);}
      if (debug){
        textSize(10);
        fill(color(100, 100, 100));
        textAlign(LEFT, TOP);
        text(str(i) + ", " + str(j), cells[i][j].x, cells[i][j].y);
      }
    }
  }

}


void settings(){
  size(screen_size, screen_size + int(screen_size * 0.2));

}
void setup(){
  println(screen_size % dimensions);
  if (screen_size % dimensions !=0){
  
    println("ERROR : screen_size must be divisible by dimensions.");
    exit();
    return;
      
  }
  frameRate(10);
  float cell_size = screen_size/dimensions;
  player_coordinates = new int[player_num * 2][2];
  cells = new Cell[int(screen_size/cell_size)][int(screen_size/cell_size)];
  
  // creating grid:
  for (int i = 0; i < dimensions; i++){
    for (int j = 0; j < dimensions; j++){
      cells[i][j] = new Cell(j * cell_size, i * cell_size, cell_size, color(255, 255, 255), "empty");      
    }
  }
  
  int right_shift = 4;
  collums_needed = int(player_num / (dimensions/2.0));
  
  
  //creating team 1:
  int w = 0;
  // go through as many collumns as you can, fitting dimensions/2 players to each collum until you run out:
  for (int i = 0; i < dimensions; i += 2){
    for (int j = 0; j < collums_needed; j++){
      cells[i + j%2][j + right_shift].update(color(255, 0, 0), "team1");
      player_coordinates[w][0] = i + j%2; 
      player_coordinates[w][1] = j + right_shift;
      w+=1;
    }
  }
  
  // add remaining players
  for (int i = 0; i < player_num % (dimensions/2); i++){
    cells[i*2 + collums_needed % 2][collums_needed + right_shift].update(color(255, 0, 0), "team1");
    player_coordinates[w][0] = i*2 + collums_needed % 2; 
    player_coordinates[w][1] = collums_needed + right_shift;
    w+=1;
  }
  
  //creating team 2:
  for (int i = 0; i < dimensions; i += 2){
    for (int j = cells[0].length - 1; j > cells[0].length - 1 - collums_needed; j--){
      cells[i + j%2][j - right_shift].update(color(0, 255, 0), "team2");
      player_coordinates[w][0] = i + j%2; 
      player_coordinates[w][1] = j - right_shift;
      w+=1;
    }
  }
  for (int i = 0; i < player_num % (dimensions/2); i++){
    try {
      cells[i*2 + (cells[0].length - 1 - collums_needed) % 2][cells[0].length - 1 - right_shift - collums_needed].update(color(0, 255, 0), "team2");
      player_coordinates[w][0] = i*2 + (cells[0].length - 1 - collums_needed) % 2; 
      player_coordinates[w][1] = cells[0].length - 1 - right_shift - collums_needed;
    w+=1;
    } catch(Exception E){
      print("Please make sure all of the requirements for the user input are properly satisfied.");
    } 
  }

  //creating ball
  ball = new Ball(cells.length/2, cells[0].length/2, ball_radius, friction, cells);
  //ball.vx = -1.5;
  //ball.vy = -1.5;
  
  generate_player_stats();
  display_grid();

}

void keyPressed(){
  if (key == 'P' || key == 'p') noLoop();
  else loop();
}
void draw(){
  background(color(255, 255, 255));
  player_decision();
  ball.move_ball(cells);
  ball.update_grid(cells, ball.ball_color, "ball"); // in case one of the player overlapped with the ball
  display_grid();
  
  String display_ = "Team 1  |" + str(team_1_goals) + "|"  + str(team_2_goals) + "|  Team 2 ";
  textSize(30);
  fill(0);
  textAlign(CENTER, CENTER);
  text(display_, screen_size/2, 1.1*screen_size);
  println(team_1_goals, team_2_goals);
}


/*
TODO:
IDEAS:
team captains coordinating attacks?
passing?
player speeds?
player striking speeds? (collision detection may be needed)
aggresion?
*/
