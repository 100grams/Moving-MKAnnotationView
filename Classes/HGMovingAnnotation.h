//
//  HGMovingAnnotation.h
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CGColor.h>
#import "HGMapPath.h"


#define kObjectMovedNotification			@"Object Moved Notification"
#define kObjectRechedEndOfPathNotification	@"Object Reached End of Path Notification"


@interface HGMovingAnnotation : NSObject<MKAnnotation> {

	MKMapPoint currentLocation;                   
	NSInteger _currentPathPointIndex;
	double _distanceTravelled;
}

- (id)	 initWithMapPath: (HGMapPath *) path;

- (void) start;
- (void) stop; 

- (void) setPath : (HGMapPath*) path; 


@property (readonly, retain) HGMapPath* path;    // path/route that this vehicle follows 
@property (readonly, assign) MKMapPoint currentLocation;  // current location of the vehicle
@property (nonatomic,assign) BOOL isMoving; 
@property (nonatomic, readonly) double distanceTravelled;


@end


