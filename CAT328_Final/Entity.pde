abstract class Entity
{
  public EntityType m_entityType;
  public CollisionType m_colliderType;
  
  public PVector m_position;
  public PVector m_velocity = new PVector(0, 0);
  public PVector m_accel = new PVector(0, 0);
  public float m_maxSpeed = 5;
  public float m_maxForce = 0.3;
  private float m_mass = 1;
  
  //used for collision detection
  public int m_sideCount; //if less than 3, it's a circle
  public float m_width, m_height; //in circle, width is used as radius
  public PVector[] m_verticies; //used in non circle, non AABox
  
  private PVector noiseOff = new PVector(random(-1,1), random(-1,1), random(-1,1));
  float randWanderTheta = 0.0f;
  float randWanderDist = 100;
  float randWanderRadius = 30;
  
  public int m_maxLookDistance = 100;
  
  protected Entity m_target;
  //protected boolean m_dead = false;
  protected int m_life;
  protected int m_lifespan = 0;
  public float m_fitness;
  
  //protected boolean m_isFriendly;
  
  /////////////////
  //CONSTRUCTORS///
  /////////////////
  Entity()
  {
    m_position = new PVector(width/2, height/2);
    m_maxSpeed = 5;
  }
  Entity(int posX, int posY, float maxSpeed, float maxForce)
  {
    m_position = new PVector(posX, posY);
    m_maxSpeed = maxSpeed;
    m_maxForce = maxForce;
  }
  
  /////////////////
  //GETS AND SETS//
  /////////////////
  public Entity getTarget()
  {
    return m_target;
  }
  public void setTarget(Entity a)
  {
    m_target = a;
  }
  public boolean isDead()
  {
    return m_life <= 0;
  }
  public PVector getPosition()
  {
    return m_position.get();
  }
  public void addLife(int time)
  {
    m_life += time;
  }
  public void setLifespan(int time)
  {
    m_lifespan = time;
  }
  public void tickLife(int dt)
  {
    if (m_life >= dt)
      m_lifespan += dt;
    else
      m_lifespan += m_life;
    m_life -= dt;
  }
  
  
  //////////////////
  ////FUNCTIONS/////
  //////////////////
  public abstract void init(PVector startPos, 
                            PVector startRot, 
                            PVector startVel,
                            int startLife,
                            float[] mults);
  public abstract void reset();
  public abstract void update();
  public abstract void render();
  public abstract void lookAround(ArrayList<Entity> entityList, EntityType eType);
  
  protected float calcRotAngle()
  {
    return atan2(m_velocity.y, m_velocity.x);
  }
  
  ////////////////////////////////////////////////////////////////////
  protected void applyForce(PVector force)
  {
    PVector f = force.get();
    f.div(m_mass);
    m_accel.add(f);
  }
  
  ////////////////////////////////////////////////////////////////////
  void updatePosition()
  {
    m_velocity.add(m_accel);
    m_position.add(m_velocity);
    m_accel.mult(0);
  }
  
  ////////////////////////////////////////////////////////////////////
  void updatePosition(float tempMaxSpd)
  {
    m_velocity.add(m_accel);
    m_velocity.normalize();
    m_velocity.mult(tempMaxSpd);
    m_position.add(m_velocity);
    m_accel.mult(0);
  }
  
  ////////////////////////////////////////////////////////////////////
  void wrapAround()
  {
    if(m_position.x < 0)
      m_position.x = width - 1;
    else if(m_position.x > width)
      m_position.x = 1;
    
    if(m_position.y < 0)
      m_position.y = height - 1;
    else if(m_position.y > height)
      m_position.y = 1;
  }
  
  ////////////////////////////////////////////////////////////////////
  protected PVector seek(float x, float y)
  {
    return seek(new PVector(x, y));
  }
  ////////////////////////////////////////////////////////////////////
  protected PVector seek(PVector target)
  {
    PVector desired = PVector.sub(target, m_position);
    desired.setMag(m_maxSpeed);
    PVector steering = PVector.sub(desired, m_velocity);
    steering.limit(m_maxForce);
    return steering;
  }
  
  ////////////////////////////////////////////////////////////////////
  protected PVector arrive(float x, float y)
  {
    return arrive(new PVector(x, y));
  }
  ////////////////////////////////////////////////////////////////////
  protected PVector arrive(PVector target)
  {
    PVector desired = PVector.sub(target, m_position);
    float d = desired.mag();
    if (d < 100)
    {
      float m = map(d, 0, 100, 0, m_maxSpeed);
      desired.setMag(m);
    }
    else
    {
      desired.setMag(m_maxSpeed);
    }
    PVector steering = PVector.sub(desired, m_velocity);
    steering.limit(m_maxForce);
    return steering;
  }
  
  ////////////////////////////////////////////////////////////////////
  protected PVector flee(PVector target)
  {
    
    PVector steering;
    PVector desired = PVector.sub(m_position, target);
    float distance = desired.mag();
    if(distance > 0.01 && distance < m_maxLookDistance)
    {
      println(distance);
      //mustFlee = true;
      desired.setMag(m_maxSpeed);
      steering = PVector.sub(desired, m_velocity);
    }
    else
    {
      steering = new PVector(0, 0);
    }
    
    //no need to limit since it's already checked the distance
    return steering;
  }
  
  ////////////////////////////////////////////////////////////////////
  //may need to adjust this//
  void pursue(Entity a)
  {
    PVector aVel = a.m_velocity.get();
    
    //set mag if looking ahead a set amount instead of
    //an amount determined by their velocity
    aVel.setMag(10); //how far ahead are we looking
    PVector predictedLoc = PVector.add(a.m_position, aVel);
    arrive(predictedLoc);
  }
  
  ////////////////////////////////////////////////////////////////////
  PVector evade(Entity a)
  {
    PVector aVel = a.m_velocity.get();
    
    //set mag if looking ahead a set amount instead of
    //an amount determined by their velocity
    aVel.setMag(10); //how far ahead are we looking
    PVector predictedLoc = PVector.add(a.m_position, aVel);
    if(this != a)
      return flee(predictedLoc);
    else
      return null;
  }
  
/*  ////////////////////////////////////////////////////////////////////
  void follow(Path p)
  {
    PVector predict = m_velocity.get();
    predict.setMag(25);
    PVector predictLoc = PVector.add(m_position, predict);
    
    PVector a = p.m_begin;
    PVector b = p.m_end;
    PVector normalPoint = getNormalPoint(predictLoc, a, b);
    
    PVector dir = PVector.sub(b, a);
    dir.setMag(10);
    PVector target = PVector.add(normalPoint, dir);
    
    float dist = PVector.dist(normalPoint, predictLoc);
    if (dist > p.m_radius)
    {
      seek(target);
    }
  }
*/  
  ////////////////////////////////////////////////////////////////////
  PVector getNormalPoint(PVector point, PVector lineStart, PVector lineEnd)
  {
    PVector startToPoint = PVector.sub(point, lineStart);
    PVector line = PVector.sub(lineEnd, lineStart);
    line.normalize();
    line.mult(startToPoint.dot(line));
    return PVector.add(lineStart, line);
  }
  
  ////////////////////////////////////////////////////////////////////
  PVector separate(ArrayList<Entity> entities)
  {
    PVector sum = new PVector();
    int count = 0;
    for(Entity other : entities)
    {
      float d = PVector.dist(m_position, other.m_position);
      if(d > 0 && d < m_maxLookDistance)
      {
        PVector diff = PVector.sub(m_position, other.m_position);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }
    
    if(count > 0)
    {
      sum.div(count);
      sum.normalize();
      sum.mult(m_maxSpeed);
      PVector steer = PVector.sub(sum, m_velocity);
      steer.limit(m_maxForce);
      return steer;
    }
    else
    {
      return new PVector(0,0); 
    }
  }
  
  ////////////////////////////////////////////////////////////////////
  PVector align(ArrayList<Entity> entities)
  {
    PVector sum = new PVector();
    int count = 0;
    for(Entity other : entities)
    {
      float d = PVector.dist(m_position, other.m_position);
      if(d > 0 && d < m_maxLookDistance)
      {
        sum.add(other.m_velocity);
        count++;
      }
    }
    
    if(count > 0)
    {
      sum.div(count);
      sum.normalize();
      sum.mult(m_maxSpeed);
      PVector steer = PVector.sub(sum, m_velocity);
      steer.limit(m_maxForce);
      return steer;
    }
    else
    {
      return new PVector(0,0);
    }
  }
  
  ////////////////////////////////////////////////////////////////////
  PVector cohesion (ArrayList<Entity> entities)
  {
    PVector sum = new PVector();
    int count = 0;
    for(Entity other : entities)
    {
      float d = PVector.dist(m_position, other.m_position);
      if(d > 0 && d < m_maxLookDistance)
      {
        sum.add(other.m_position);
        count++;
      }
    }
    
    if(count > 0)
    {
      sum.div(count);
      return seek(sum);
    }
    else
    {
      return new PVector(0,0);
    }
  }
  
  ////////////////////////////////////////////////////////////////////
  void noiseWander()
  {
    float theta = map( noise(noiseOff.x, noiseOff.y), 0, 1, 0, TWO_PI);
//    println(cos(theta));
    float dx = map(cos(theta), -1, 0, -1, 1);
//    println(dx);
    PVector dest = PVector.add(new PVector(dx, sin(theta)), m_position);
    seek(dest);
    noiseOff.add(0.01, 0.01, 0);
  }
}
