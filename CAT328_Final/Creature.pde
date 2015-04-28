public class Creature extends Entity
{
  public float plantSeekMult, plantFleeMult, plantAlignMult, plantSeperateMult, plantCoheseMult; 
  public float herbSeekMult, herbFleeMult, herbAlignMult, herbSeperateMult, herbCoheseMult;
  
  PVector m_startPos, m_startRot, m_startVel;
  int m_startLife;
  
  Creature()
  {
    m_maxLookDistance = 50;
  }
  
  public void init(PVector startPos, 
                   PVector startRot, 
                   PVector startVel,
                   int startLife,
                   float[] mults)
  {
    plantSeekMult = mults[0];
    plantFleeMult = mults[1];
    plantAlignMult = mults[2];
    plantSeperateMult = mults[3];
    plantCoheseMult = mults[4];
    herbSeekMult = mults[5];
    herbFleeMult = mults[6];
    herbAlignMult = mults[7];
    herbSeperateMult = mults[8];
    herbCoheseMult = mults[9];
    
    m_startPos = startPos;
    m_startRot = startRot; 
    m_startVel = startVel;
    m_startLife = startLife;
    
    reset();
  }
  
  public void reset()
  {
    m_position = m_startPos;
    m_velocity = m_startVel;
    m_life = m_startLife;
    m_lifespan = 0;
    m_fitness = 0.0f;
  }
  
  void update()
  {
    //arrive(mouseX, mouseY);
    updatePosition();
    wrapAround();
  }
  
  void render()
  {
    if(!isDead())
    {
      EntityManager.anyAlive = true;
      //push matrix
      pushMatrix();
      
      //translate and rotate
      translate(m_position.x, m_position.y);
      
      //draw
      fill(0);
      ellipse(0, 0, 10, 10);
      
      //pop matrix
      popMatrix();
    }
  }
  
  void lookAround(ArrayList<Entity> entityList, EntityType eType)
  {
    PVector sepForce = separate(entityList);
    PVector alignForce = align(entityList);
    PVector coheseForce = cohesion(entityList);
    PVector fleeForce = cohesion(entityList);
    PVector seekForce = cohesion(entityList);
    
    switch (eType)
    {
      case HERBIVORE:
        sepForce.mult(herbSeperateMult);
        alignForce.mult(herbAlignMult);
        coheseForce.mult(herbCoheseMult);
        fleeForce.mult(herbFleeMult);
        seekForce.mult(herbSeekMult);
        break;
        
        
      default: //plant
        sepForce.mult(plantSeperateMult);
        alignForce.mult(plantAlignMult);
        coheseForce.mult(plantCoheseMult);
        fleeForce.mult(plantFleeMult);
        seekForce.mult(plantSeekMult);
    }
    
    applyForce(sepForce);
    applyForce(alignForce);
    applyForce(coheseForce);
    applyForce(fleeForce);
    applyForce(seekForce);
  }
  
}
