public static class EntityManager
{
  static HashMap<EntityType, ArrayList<Entity>> m_entityLists = new HashMap();
  public static boolean anyAlive;
  
  public static float mutationRate = 0.01f;
  
  EntityManager()
  {
    m_entityLists = new HashMap();
  }
  EntityManager(EntityType[] types)
  {
    for(EntityType s : types)
    {
      addType(s);
    }
  }
  
  //////////////////////////////////////////////////////////////////////
  public static ArrayList getList(String listName)
  {
    if(m_entityLists.containsKey(listName))
    {
      return m_entityLists.get(listName);
    }
    return null;
  }
  public static void addEntity(EntityType entityType, Entity e)
  {
    if(!m_entityLists.containsKey(entityType))
    {
      println("TYPE NOT FOUND, ANIMAL NOT ADDED");
    }
    else
    {
      m_entityLists.get(entityType).add(e);
    }
  }
  public static void addType(EntityType entityType)
  {
    if(!m_entityLists.containsKey(entityType))
    {
      m_entityLists.put(entityType, new ArrayList<Entity>());
    } 
  }
  
  //////////////////////////////////////////////////////////////////////
  public static void updateAll()
  {
    for(EntityType keys : m_entityLists.keySet())
    {
      for(Entity e : m_entityLists.get(keys))
      {
        e.update();
      }
    }
  }
  public static void renderAll()
  {
    for(EntityType keys : m_entityLists.keySet())
    {
      for(Entity e : m_entityLists.get(keys))
      {
        e.render();
      }
    }
  }
  
  //////////////////////////////////////////////////////////////////////
  //looking around functions
  //////////////////////////////////////////////////////////////////////
  public static void allLook()
  {
    for(EntityType keys : m_entityLists.keySet()) //for each list
    {
      for(Entity e : m_entityLists.get(keys)) //for each animal in each list
      {
        for(EntityType entityListKey : m_entityLists.keySet()) //send the animal every entity list to look at
        {
          e.lookAround(m_entityLists.get(entityListKey), entityListKey);
        }
      }
    }
  }
  public static void allLookAt(EntityType targets)
  {
    ArrayList<Entity> targetList = m_entityLists.get(targets);
    
    for(EntityType keys : m_entityLists.keySet()) //for each list
    {
      for(Entity e : m_entityLists.get(keys)) //for each animal in each list
      {
        e.lookAround(targetList, targets);
      }
    }
  }
/*  public static void allLookAt(ArrayList<Entity> lookers, ArrayList<Entity> targets)
  {
    for(Entity animal : lookers) //for each animal in each list
    {
      animal.lookAround(targets);
    }
  }
  public static void allLookAt(String lookers, String targets)
  {
    allLookAt(m_animalLists.get(lookers), m_animalLists.get(targets));
  }
*/

  //////////////////////////////////////////////////////////////////////
  public static void updateDT(int dt)
  {
    for(EntityType keys : m_entityLists.keySet()) //for each list
    {
      for(Entity e : m_entityLists.get(keys)) //for each animal in each list
      {
        e.tickLife(dt);
      }
    }
  }
  //////////////////////////////////////////////////////////////////////
  //fitness and repopulation functions
  //////////////////////////////////////////////////////////////////////
  public static void createNewPopulation()
  {
    evalFitness();
    selectionAndReproduction();
    
  }
  //////////////////////////////////////////////////////////////////////
  private static void evalFitness()
  {
    int maxLifespan = 0;
    for(EntityType keys : m_entityLists.keySet()) //for each list
    {
      for(Entity e : m_entityLists.get(keys)) //for each animal in each list
      {
        if (maxLifespan < e.m_lifespan)
        {
          maxLifespan = e.m_lifespan;
        }
      }
    }
    
    for(EntityType keys : m_entityLists.keySet()) //for each list
    {
      for(Entity e : m_entityLists.get(keys)) //for each animal in each list
      {
        e.m_fitness = (float)(e.m_lifespan) / maxLifespan;
      }
    }
  }
  //////////////////////////////////////////////////////////////////////
  private static void selectionAndReproduction()
  {
    for(EntityType keys : m_entityLists.keySet()) //for each list
    {
      HashMap<Integer, Entity> matingPool = new HashMap<Integer, Entity>();
      
      switch (keys)
      {
      case HERBIVORE:
        int x = 0;
        for(Entity e : m_entityLists.get(keys)) //for each animal in each list
        {
          int n = (int)(e.m_fitness * 100);
          for (int i = 0; i < n; i ++)
          {
            //println(i + x);
            matingPool.put(i + x, e);
          }
          x += n;
        }
        
        //ArrayList<Entity> nextGen = new ArrayList<Entity>();
        for(Entity e : m_entityLists.get(keys))
        {
          int a = (int)(Math.random() * matingPool.size());
          int b = (int)(Math.random() * matingPool.size());
          
          Creature p1 = (Creature)matingPool.get(a);
          Creature p2 = (Creature)matingPool.get(b);
          
  /*        while (p1 == null)
          {
            //println("p1 not found at: " + a);
            p1 = (Creature)matingPool.get(++a);
          }
          while (p2 == null)
          {
            //println("p2 not found at: " + b);
            p2 = (Creature)matingPool.get(++b);
          }
  */        
          
          ((Creature)e).plantSeekMult = (int)(Math.random() * 10)%2 == 0 ? p1.plantSeekMult : p2.plantSeekMult;
          ((Creature)e).plantFleeMult = (int)(Math.random() * 10)%2 == 0 ? p1.plantFleeMult : p2.plantFleeMult;
          ((Creature)e).plantAlignMult = (int)(Math.random() * 10)%2 == 0 ? p1.plantAlignMult : p2.plantAlignMult;
          ((Creature)e).plantSeperateMult = (int)(Math.random() * 10)%2 == 0 ? p1.plantSeperateMult : p2.plantSeperateMult;
          ((Creature)e).plantCoheseMult = (int)(Math.random() * 10)%2 == 0 ? p1.plantCoheseMult : p2.plantCoheseMult;
          ((Creature)e).herbSeekMult = (int)(Math.random() * 10)%2 == 0 ? p1.herbSeekMult : p2.herbSeekMult;
          ((Creature)e).herbFleeMult = (int)(Math.random() * 10)%2 == 0 ? p1.herbFleeMult : p2.herbFleeMult;
          ((Creature)e).herbAlignMult = (int)(Math.random() * 10)%2 == 0 ? p1.herbAlignMult : p2.herbAlignMult;
          ((Creature)e).herbSeperateMult = (int)(Math.random() * 10)%2 == 0 ? p1.herbSeperateMult : p2.herbSeperateMult;
          ((Creature)e).herbCoheseMult = (int)(Math.random() * 10)%2 == 0 ? p1.herbCoheseMult : p2.herbCoheseMult;
          
          //mutation check
          if (Math.random() <= mutationRate) ((Creature)e).plantSeekMult = (float)Math.random() * 10;
          if (Math.random() <= mutationRate) ((Creature)e).plantFleeMult = (float)Math.random() * 10;
          if (Math.random() <= mutationRate) ((Creature)e).plantAlignMult = (float)Math.random() * 10;
          if (Math.random() <= mutationRate) ((Creature)e).plantSeperateMult = (float)Math.random() * 10;
          if (Math.random() <= mutationRate) ((Creature)e).plantCoheseMult = (float)Math.random() * 10;
          if (Math.random() <= mutationRate) ((Creature)e).herbSeekMult = (float)Math.random() * 10;
          if (Math.random() <= mutationRate) ((Creature)e).herbFleeMult = (float)Math.random() * 10;
          if (Math.random() <= mutationRate) ((Creature)e).herbAlignMult = (float)Math.random() * 10;
          if (Math.random() <= mutationRate) ((Creature)e).herbSeperateMult = (float)Math.random() * 10;
          if (Math.random() <= mutationRate) ((Creature)e).herbCoheseMult = (float)Math.random() * 10;
          
          e.reset();
        }
        break;
      case PLANT:
        
        break;
      default:
      }//end switch
    }
  }
}






