import math
 
proc distance_on_unit_sphere(lat1, long1, lat2, long2):float =
 
    # adapted from 
    # http://www.johndcook.com/blog/python_longitude_latitude/
    
    # Convert latitude and longitude to 
    # spherical coordinates in radians.
    var degrees_to_radians = PI/180.0
         
    # phi = 90 - latitude
    var phi1 = (90.0 - lat1) * degrees_to_radians
    var phi2 = (90.0 - lat2) * degrees_to_radians
         
    # theta = longitude
    var theta1 = long1 * degrees_to_radians
    var theta2 = long2 * degrees_to_radians
         
    # Compute spherical distance from spherical coordinates.
         
    # For two locations in spherical coordinates 
    # (1, theta, phi) and (1, theta, phi)
    # cosine( arc length ) = 
    #    sin phi sin phi' cos(theta-theta') + cos phi cos phi'
    # distance = rho * arc length
     
    var zcos = (math.sin(phi1) * math.sin(phi2) * math.cos(theta1 - theta2) + 
           math.cos(phi1) * math.cos(phi2))
    
    var arc = math.arccos( zcos )
    var earth_radius = 6378.388
    var rv = arc * earth_radius
    result = rv

# http://mygeoposition.com/   
echo()
echo "London , Downing Street - Auburn Alabama"
var arcdist = distance_on_unit_sphere(51.5033630,-0.1276250,32.627837,-85.445105  )

echo "Distance : ",arcdist ," km"
echo "Distance : ",arcdist/1.60934 ," miles"
echo ()