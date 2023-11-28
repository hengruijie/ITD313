register 'udf.py' using jython as myfunc;
POINTS = load 'data/points' using PigStorage('\t') as (x:double,y:double);
CENTROIDS = load 'data/centroids' using PigStorage('\t') as (cx:double,cy:double);
GC = foreach (group CENTROIDS all) generate $1 as centroids;
POINTS_AND_CENTROIDS = CROSS POINTS, GC;
POINTS_WITH_NEAREST_CENTROID = foreach POINTS_AND_CENTROIDS generate x, y, myfunc.nearest_centroid(x,y,centroids) as centroid;
CLUSTERS = group POINTS_WITH_NEAREST_CENTROID by centroid;
NEWCENTROIDS = foreach CLUSTERS generate myfunc.mean(POINTS_WITH_NEAREST_CENTROID) as newcentroid;
OUT = foreach NEWCENTROIDS generate newcentroid.mx, newcentroid.my;
store OUT into 'data/newcentroids' using PigStorage('\t');