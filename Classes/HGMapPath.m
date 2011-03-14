//
//  HGMapPath.m
//  HGMovingAnnotationSample
//
//  Created by Rotem Rubnov on 14/3/2011.
//	Copyright (C) 2011 100 grams software
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//


#import "HGMapPath.h"


#define INITIAL_POINT_SPACE 1000


@interface HGMapPath ()

// Initialize the HGMapPath with the starting coordinate.
- (id)initWithCoordinate : (CLLocationCoordinate2D) coordinate;

// building the path 
- (void) addCoordinate : (CLLocationCoordinate2D) coordinate;
- (void) addPoint :(MKMapPoint)newPoint;
- (CLLocationCoordinate2D) coordinateFromNmeaLogline : (NSString *)line;

- (void) processPathData : (NSData*)data;

@end



@implementation HGMapPath

@synthesize points, pointCount;


- (id) initFromFile : (NSString *) file
{
  
  if(self = [super init])
  {
    // initialize point storage and place this first coordinate in it
    pointSpace = INITIAL_POINT_SPACE;
    points = malloc(sizeof(MKMapPoint) * pointSpace);
    pointCount = 0;
    
    NSData *data = [NSData dataWithContentsOfFile:file];
	
	  [self performSelectorInBackground:@selector(processPathData:) withObject:data];
	  
  }
  return self;
}


- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
{
  if ([self init]) {
    points[0] = MKMapPointForCoordinate(coord);
    pointCount = 1;    
  }
  return self;
}


- (void)dealloc
{
  free(points);
  [super dealloc];
}



- (void) processPathData : (NSData*)data;
{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

  [dataString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
    
	CLLocationCoordinate2D coordinate = [self coordinateFromNmeaLogline : line];
      
	if (!pointCount)
	  [self initWithCoordinate : coordinate];
	else
	  [self addCoordinate : coordinate];
	
	}]; 
	     
	[[NSNotificationCenter defaultCenter] postNotificationName:kPathLoadedNotification object:self]; 

}


- (CLLocationCoordinate2D) coordinateFromNmeaLogline : (NSString *)line
{
  
  NSArray *locationFields = [line componentsSeparatedByString:@","]; 
  
  double nmeaLat = [[locationFields objectAtIndex:0] doubleValue];
  NSString *directionLat = [locationFields objectAtIndex:1];
  if([directionLat characterAtIndex:0] == 'S')
    nmeaLat = -nmeaLat;
  double nmeaLong = [[locationFields objectAtIndex:2] doubleValue]; 
  NSString *directionLong = [locationFields objectAtIndex:3];
  if([directionLong characterAtIndex:0] == 'W')
    nmeaLong = -nmeaLong;
  
  //convert from NMEA, i.e. degrees/minutes/decimalMinutes (ddmm.mmm) to degrees/decimalDegrees (dd.ddddd)
  int degrees = nmeaLong / 100; 
  double minutes = nmeaLong - degrees*100;
  CLLocationDegrees longitude = degrees + minutes/60;
  degrees = nmeaLat / 100; 
  minutes = nmeaLat - degrees*100;
  CLLocationDegrees latitude = degrees + minutes/60; 
  
  return   CLLocationCoordinate2DMake( latitude,  longitude); 
}



- (void) addCoordinate : (CLLocationCoordinate2D) coordinate
{
	[self addPoint:MKMapPointForCoordinate(coordinate)];
}


- (void)addPoint:(MKMapPoint)newPoint;
{  
  // Convert a CLLocationCoordinate2D to an MKMapPoint
  MKMapPoint prevPoint = points[pointCount - 1];
  
  // Get the distance between this new point and the previous point.
  CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint, prevPoint);
  
  if (metersApart > MINIMUM_METERS_BETWEEN_PATH_POINTS) {
    // Grow the points array if necessary
    if (pointSpace == pointCount) {
      pointSpace *= 2;
      points = realloc(points, pointSpace  * sizeof(points[0]));
    }    
    
    // Add the new point to the points array
    points[pointCount] = newPoint;
    pointCount++;
        
  }  
}


@end
