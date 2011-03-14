//
//  HGMovingAnnotation.m
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

#import "HGMovingAnnotation.h"


#define DEMO_SPEED 1.0 //seconds between path points


@interface HGMovingAnnotation () 

- (void) startTracking;


@property (readwrite, retain) HGMapPath* path;    // path/route that this vehicle follows 
@property (readwrite, assign) MKMapPoint currentLocation;  // current location of the vehicle

@end



@implementation HGMovingAnnotation

@synthesize path; 
@synthesize currentLocation, distanceTravelled; 
@synthesize isMoving;

 
- (id) initWithMapPath: (HGMapPath *) aPath;
{
	self = [super init];
	if (self != nil) {
		self.path = aPath;
		_currentPathPointIndex = 0;
		self.currentLocation = self.path.points[_currentPathPointIndex];
		_distanceTravelled = 0.0;
		self.isMoving = NO;
	}

	return self;
}

- (void) dealloc
{
  self.path = nil;
  [super dealloc];
}


//start tracking vehicle locations. In DEMO mode just read locations from the path...
- (void) start
{
  [self performSelectorInBackground:@selector(startTracking) withObject:nil];
}

- (void) stop 
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  self.isMoving = NO;
}


- (void) startTracking
{
	self.isMoving = YES; 

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  for(int i=_currentPathPointIndex+1; i<path.pointCount; i++)
  {
	  
    currentLocation = self.path.points[i]; 
    
    _distanceTravelled += MKMetersBetweenMapPoints(self.path.points[i], self.path.points[i-1]);
        
	  //send notification
	  [[NSNotificationCenter defaultCenter] postNotificationName:kObjectMovedNotification object:self]; 

	  [NSThread sleepForTimeInterval : DEMO_SPEED];
  }
  
  //finished moving along the path - send notification
  [[NSNotificationCenter defaultCenter] postNotificationName:kObjectRechedEndOfPathNotification object:self]; 

  [pool drain];
}



#pragma mark -
#pragma mark MKAnnotation

- (CLLocationCoordinate2D) coordinate
{
	return MKCoordinateForMapPoint(currentLocation);
}



- (NSString*) title
{
	return @"My Moving Object";
}

- (NSString*) subtitle
{
	return [NSString stringWithFormat:@"%.3f,%.3f", self.coordinate.latitude, self.coordinate.longitude];
}
	

@end 
