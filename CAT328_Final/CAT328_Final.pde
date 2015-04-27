

public static final int FLOCKER_COUNT = 50;
public static final int BG_COLOR = 0xFFFFFFFF;

int lastMilli;

void setup()
{
  //setup screen
  size(800, 800);
  
  //create starting entities
  EntityManager.addType(EntityType.HERBIVORE);
  for(int i = 0; i < FLOCKER_COUNT; i++)
  {
    Creature herb = new Creature();
    float[] mults = new float[10];
    for (int j = 0; j < mults.length; j++)
    {
      mults[j] = random(0, 2);
    }
    herb.init(new PVector(0, width/2),
              new PVector(0, 0),
              new PVector(random(-1, 1), random(-1, 1)),
              2500,
              mults);
              
/*    herb.m_position.x = random(0, width);
    herb.m_position.y = random(0, height);
    
    herb.m_velocity.x = random(-1, 1);
    herb.m_velocity.y = random(-1, 1);
    herb.m_velocity.setMag(herb.m_maxSpeed);
    herb.addLife(5000);
    herb.plantSeekMult = random(0, 10);
    herb.plantFleeMult = random(0, 10);
    herb.plantAlignMult = random(0, 10);
    herb.plantSeperateMult = random(0, 10);
    herb.plantCoheseMult = random(0, 10);
    herb.herbSeekMult = random(0, 10);
    herb.herbFleeMult = random(0, 10);
    herb.herbAlignMult = random(0, 10);
    herb.herbSeperateMult = random(0, 10);
    herb.herbCoheseMult = random(0, 10);
*/
    EntityManager.addEntity(EntityType.HERBIVORE, herb);
  }
  //EntityManager.addType(EntityType.PLANT);
  //Plant p = new Plant();
  //p.m_position = new PVector(width/2, height/2);
  //EntityManager.addEntity(EntityType.PLANT, p);  
}

void draw()
{
  //clear BG
  background(BG_COLOR);
  
  //reset bool to hold if anyone is alive
  EntityManager.anyAlive = false;
  //update entities
  int thisMilli = millis();
//  println(thisMilli - lastMilli);
  EntityManager.updateDT(thisMilli - lastMilli);
  lastMilli = thisMilli;
  
  EntityManager.allLook();
  EntityManager.updateAll();
  EntityManager.renderAll();
  
  if (!EntityManager.anyAlive)
  {
    EntityManager.createNewPopulation();
    println("New Population Created");
  }
}

void keyPressed()
{
}

void mouseClicked()
{
}
