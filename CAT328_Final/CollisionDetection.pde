//FIX checkPolyPolySeparation

public static class CollisionDetection
{
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns true if colliding, false otherwise
  public static Boolean collisionTest(Entity e1, Entity e2)
  {
    if(e1.m_colliderType == CollisionType.CONVEX_POLY || e2.m_colliderType == CollisionType.CONVEX_POLY)
    {
      return separatingAxisTest(e1, e2);
    }
    
    if(e1.m_colliderType == CollisionType.CIRCLE)
    {
      if(e2.m_colliderType == CollisionType.CIRCLE)
      {
        return circleCircleTest(e1, e2);
      }
      else if(e2.m_colliderType == CollisionType.AABOX)
      {
        return circleAABoxTest(e1, e2);
      }
    }
    else if(e1.m_colliderType == CollisionType.AABOX)
    {
      if(e2.m_colliderType == CollisionType.CIRCLE)
      {
        return circleAABoxTest(e2, e1);
      }
      else if(e2.m_colliderType == CollisionType.AABOX)
      {
        return AABoxAABoxTest(e1, e2);
      }
    }
    
    //a collider was not set properly, return NULL
    return null;
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns true if colliding, false otherwise
  public static boolean circleCircleTest(Entity e1, Entity e2)
  {
    //width used as radius in all circles
    return PVector.dist(e1.m_position, e2.m_position) < (e1.m_width + e2.m_width);
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns true if colliding, false otherwise
  public static boolean circleAABoxTest(Entity c, Entity b)
  {
    float radius = c.m_width;
    float boxLeft = b.m_position.x - (b.m_width / 2);
    float boxRight = b.m_position.x + (b.m_width / 2);
    float boxTop = b.m_position.y - (b.m_height / 2);
    float boxBottom = b.m_position.y + (b.m_height / 2);
    
    boolean centerIsRightOfLeft = boxLeft <= c.m_position.x;
    boolean centerIsLeftOfRight = boxRight >= c.m_position.x;
    boolean centerIsBelowTop = boxTop <= c.m_position.y;
    boolean centerIsAboveBottom = boxBottom >= c.m_position.y;
  
    //test where circle center is in relation to rect
    //return collision test
    if (centerIsRightOfLeft)
    {
      if (centerIsLeftOfRight)
      {
        if (centerIsBelowTop)
        {
          if (centerIsAboveBottom) // center is inside rect
            return true;
          else // center is below rect
            return ( boxBottom >= (c.m_position.y - radius) );
        }
        else // center is above rect
          return (boxTop <= (c.m_position.y + radius) );
      }
      //center is to the right of rect... somewhere
      else if (centerIsBelowTop) 
      {
        if (centerIsAboveBottom) // center right
          return (boxRight >= (c.m_position.x - radius) );
        else // center is right AND below
        {
          PVector corner = new PVector(boxRight, boxBottom);
          float dist = PVector.dist(corner, c.m_position);
          return (dist <= radius);
        }
      }
      else // center is right AND above
      {
        PVector corner = new PVector(boxRight, boxTop);
        float dist = PVector.dist(corner, c.m_position);
        return (dist <= radius);
      }
    }
    //center is to left of rect... somewhere
    else if (centerIsBelowTop) 
    {
      if (centerIsAboveBottom) // center left
        return (boxLeft <= (c.m_position.x + radius) );
      else // center is left AND below
      {
        PVector corner = new PVector(boxLeft, boxBottom);
        float dist = PVector.dist(corner, c.m_position);
        return (dist <= radius);
      }
    }
    else // center is left AND above
    {
      PVector corner = new PVector(boxLeft, boxTop);
      float dist = PVector.dist(corner, c.m_position);
      return (dist <= radius);
    }
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns true if colliding, false otherwise
  public static boolean AABoxAABoxTest(Entity e1, Entity e2)
  {
    PVector boxOneMin = new PVector(e1.m_position.x - e1.m_width, e1.m_position.y - e1.m_height);
    PVector boxOneMax = new PVector(e1.m_position.x + e1.m_width, e1.m_position.y + e1.m_height);
    PVector boxTwoMin = new PVector(e2.m_position.x - e2.m_width, e2.m_position.y - e2.m_height);
    PVector boxTwoMax = new PVector(e2.m_position.x + e2.m_width, e2.m_position.y + e2.m_height);
    
    if (boxOneMin.x > boxTwoMax.x)
    {
      return false;
    }
    if (boxOneMin.y > boxTwoMax.y)
    {
      return false;
    }
    if (boxOneMax.x < boxTwoMin.x)
    {
      return false;
    }
    if (boxOneMax.y < boxTwoMin.y)
    {
      return false;
    }
    return true;
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns true if colliding, false otherwise
  public static boolean separatingAxisTest(Entity e1, Entity e2)
  {
    //handle if either one is a circle
    Entity circle = null;
    Entity poly = null;
    if(e1.m_colliderType == CollisionType.CIRCLE)
    {
      circle = e1;
      poly = e2;
    }
    else if(e2.m_colliderType == CollisionType.CIRCLE)
    {
      circle = e2;
      poly = e1;
    }
    
    boolean separated;
    if(circle != null) //THERE IS A CIRCLE
    {
      PVector closestVert = findClosestVertex(circle, poly);
      separated = checkCirclePolySeparation(circle, poly);
    }
    else //THERE IS NO CIRCLE
    {
      //sep axis between two convex polygons
      separated = checkPolyPolySeparation(e1, e2);
    }
    
    return !separated;
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  private static boolean checkPolyPolySeparation(Entity e1, Entity e2)
  {
    boolean isSeparated = false;
    //check normals of e1
    for(int i = 0; i < e1.m_sideCount; i++)
    {
      //x = min, y = max
      PVector e1MinMax = new PVector(0, 0);// = e1.getMinMax(e1.normal[i]);
      PVector e2MinMax = new PVector(0, 0);// = e2.getMinMax(e1.normal[i]);
      
      isSeparated = e1MinMax.x > e2MinMax.y || e2MinMax.x > e1MinMax.y;
      if(isSeparated)
      {
        return true;
      }
    }
    //check normals of e2
    for(int i = 0; i < e2.m_sideCount; i++)
    {
      //x = min, y = max
      PVector e1MinMax = new PVector(0, 0);// = e1.getMinMax(e2.normal[i]);
      PVector e2MinMax = new PVector(0, 0);// = e2.getMinMax(e2.normal[i]);
      
      isSeparated = e1MinMax.x > e2MinMax.y || e2MinMax.x > e1MinMax.y;
      if(isSeparated)
      {
        return true;
      }
    }
    //all tests done, they are not separated.
    return false;
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  public static boolean checkCirclePolySeparation(Entity circle, Entity poly)
  {
    PVector closestPt;
    PVector secondClosestPt;
    closestPt = findClosestVertex(circle, poly);
    
    //check if closest point intersects with circle
    if(circlePointTest(circle, closestPt))
    {
      return false;
    }
    //check if line between two closest points intersects with circle
    secondClosestPt = findSecondClosestVertex(circle, poly);
    
    return !circleLineTest(circle, closestPt, secondClosestPt);
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  public static PVector findClosestVertex(Entity circle, Entity poly)
  {
    PVector closestPoint = poly.m_verticies[0];
    float closestDist = PVector.dist(circle.m_position, closestPoint);
    for(int i = 1; i < poly.m_verticies.length; i++)
    {
      float tempDist = PVector.dist(circle.m_position, poly.m_verticies[i]);
      if(tempDist < closestDist)
      {
        closestDist = tempDist;
        closestPoint = poly.m_verticies[i];
      }
    }
    
    return closestPoint;
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  public static PVector findSecondClosestVertex(Entity circle, Entity poly)
  {
    PVector closestPoint = findClosestVertex(circle, poly);
    PVector secondClosestPt;
    float secondClosestDist;
    
    if(closestPoint.x == poly.m_verticies[0].x && closestPoint.y == poly.m_verticies[0].y)
    {
      secondClosestPt = poly.m_verticies[1];
    }
    else
    {
      secondClosestPt = poly.m_verticies[0];
    }
    secondClosestDist = PVector.dist(circle.m_position, secondClosestPt);

    for(int i = 1; i < poly.m_verticies.length; i++)
    {
      if(!(closestPoint.x == poly.m_verticies[i].x && closestPoint.y == poly.m_verticies[i].y))
      {
        float tempDist = PVector.dist(circle.m_position, poly.m_verticies[i]);
        if(tempDist < secondClosestDist)
        {
          secondClosestDist = tempDist;
          secondClosestPt = poly.m_verticies[i];
        }
      }
    }
    
    return secondClosestPt;
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns true if colliding, false otherwise
  public static boolean circlePointTest(Entity c, PVector point)
  {
    return PVector.dist(c.m_position, point) < c.m_width;
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns true if colliding, false otherwise
  public static boolean circleLineTest(Entity c, PVector lineStart, PVector lineEnd)
  {
    //get normal point from line to circle center
    PVector normPoint = getNormalPoint(c.m_position, lineStart, lineEnd);
    //compare that dist to center.
    return circlePointTest(c, normPoint);
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  public static PVector getNormalPoint(PVector point, PVector lineStart, PVector lineEnd)
  {
    PVector startToPoint = PVector.sub(point, lineStart);
    PVector line = PVector.sub(lineEnd, lineStart);
    line.normalize();
    line.mult(startToPoint.dot(line));
    return PVector.add(lineStart, line);
  }
}
