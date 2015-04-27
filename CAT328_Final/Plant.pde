public class Plant extends Entity
{
  public void init(PVector startPos, 
                            PVector startRot, 
                            PVector startVel,
                            int startLife,
                            float[] mults)
  {
  }
                            
  public void reset()
  {
  }
   void update()
  {
  }
  
  void render()
  {
    //push matrix
    pushMatrix();
    
    //translate and rotate
    translate(m_position.x, m_position.y);
    
    //draw
    fill(0);
    rect(0, 0, 10, 10);
    
    //pop matrix
    popMatrix();
  }
  
  public void lookAround(ArrayList<Entity> entityList, EntityType eType)
  {
  }
}
