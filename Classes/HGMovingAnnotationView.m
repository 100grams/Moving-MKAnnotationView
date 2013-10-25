//
//  HGMovingAnnotationView.m
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

#import "HGMovingAnnotationView.h"
#import "HGMovingAnnotation.h"
#import <QuartzCore/QuartzCore.h>

#define POSITIONKEY @"positionAnimation"
#define BOUNDSKEY @"boundsAnimation"


static NSString *HGMovingAnnotationTransformsKey = @"TransformsGroupAnimation";


//@interface HGMovingAnnotationView()
//- (void) setPosition : (id) pos; 
//@end


@implementation HGMovingAnnotationView

#pragma mark
- (id) initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
		self.canShowCallout = YES;
		self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	}
	return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.layer removeAllAnimations];
    self.mapView = nil;
}



- (void)setAnnotation:(id <MKAnnotation>)anAnnotation
{
    if (anAnnotation) {
        if (anAnnotation != self.annotation) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMoveAnnotation:) name:kObjectMovedNotification object:anAnnotation];
        }
    }
    else {
        //		DLog(DEBUG_LEVEL_ERROR, @"%x removed. Clearing annotation object %x", self, anAnnotation);
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.layer removeAllAnimations];
        self.mapView = nil;
    }
    
    [super setAnnotation :anAnnotation];
    
    if (self.mapView && anAnnotation) {
        [self updateTransformsFromAnnotation:(HGMovingAnnotation*) anAnnotation animated:NO];
    }
    
    
}


- (void) didMoveAnnotation : (NSNotification*) notification 
{
    [self updateTransformsFromAnnotation:[notification object] animated:YES];
}



//- (void) setPosition : (id) posValue; 
//{
//	//extract the mapPoint from this dummy (wrapper) CGPoint struct
//	MKMapPoint mapPoint = *(MKMapPoint*)[(NSValue*)posValue pointerValue];  
//	
//	//now properly convert this mapPoint to CGPoint 
//	CGPoint toPos;
//	CGFloat zoomFactor =  self.mapView.visibleMapRect.size.width / self.mapView.bounds.size.width;
//	toPos.x = mapPoint.x/zoomFactor;
//	toPos.y = mapPoint.y/zoomFactor;
//	
//	if (MKMapRectContainsPoint(self.mapView.visibleMapRect, mapPoint)) {
//
//		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
//		
//		animation.fromValue = [NSValue valueWithCGPoint:self.center];
//		animation.toValue = [NSValue valueWithCGPoint:toPos];	
//		animation.duration = 0.3;
//		animation.delegate = self;
//		animation.fillMode = kCAFillModeForwards;
//		//[self.layer removeAllAnimations];
//		[self.layer addAnimation:animation forKey:POSITIONKEY];
//		
//		//NSLog(@"setPosition ANIMATED %x from (%f, %f) to (%f, %f)", self, self.center.x, self.center.y, toPos.x, toPos.y);
//	}	
//	
//	self.center = toPos;
//
//
//	
//}




- (void)updateTransformsFromAnnotation:(HGMovingAnnotation*)annotation animated:(BOOL)animated
{
    CLLocationCoordinate2D coordinate = annotation.coordinate;
    
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        
        NSMutableDictionary *transforms = [NSMutableDictionary dictionaryWithCapacity:2];
        [transforms setValue:[NSValue valueWithMKCoordinate:coordinate] forKey:@"coordinate"];
        
        if ([annotation respondsToSelector:@selector(rotation)]) {
            // add rotation
            [transforms setValue:[NSNumber numberWithFloat:annotation.rotation] forKey:@"rotation"];
        }
        
        [self applyTransforms:transforms animated:animated];
        
    }
    
}


#define IS_IOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)


- (void)applyTransforms :(NSDictionary *)transforms animated:(BOOL)animated
{
    //extract the updated coordinate of the annotation from 'transforms' dictionary
    CLLocationCoordinate2D coordinate = [transforms[@"coordinate"] MKCoordinateValue];
    
    CGPoint toPos;
    if (IS_IOS7) {
        toPos = [self.mapView convertCoordinate:coordinate toPointToView:self.mapView];
    }
    else{
        MKMapPoint toMapPoint = MKMapPointForCoordinate(coordinate);
        CGFloat mapScale = round(self.mapView.visibleMapRect.size.width / self.mapView.frame.size.width);
        toPos = (CGPoint){toMapPoint.x/mapScale, toMapPoint.y/mapScale};
    }
    
    if (animated) {
        
        CAAnimationGroup *theGroup = [CAAnimationGroup animation];
        
        theGroup.duration = 0.2;
        theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        theGroup.delegate = self;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:self.center];
        animation.toValue = [NSValue valueWithCGPoint:toPos];
        
        NSMutableArray *animArray = [NSMutableArray arrayWithCapacity:2];
        [animArray addObject:animation];
        
        if ([transforms valueForKey:@"rotation"]) {
            
            CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            rotation.toValue = [transforms valueForKey:@"rotation"];
            [animArray addObject:rotation];
        }
        
        theGroup.animations = animArray;
        
        [self.layer addAnimation:theGroup forKey:HGMovingAnnotationTransformsKey];
        
    }
    else {
        // set final rotation value for the layer
        [self.layer setAffineTransform:CGAffineTransformMakeRotation([[transforms valueForKey:@"rotation"] floatValue])];
        self.center = toPos;

    }
    
    
}


- (void) animationDidStart:(CAAnimation *)anim;
{
    
    if ([anim respondsToSelector:@selector(animations)]) {
        // anim is actually CAAnimationGroup with multiple animations (namely position and rotation)
        NSArray *animations = ((CAAnimationGroup *) anim).animations;
        
        if (animations.count > 0) {
            self.layer.position = [((CABasicAnimation *) [animations objectAtIndex:0]).toValue CGPointValue];
        }
        if (animations.count > 1) {
            // set final rotation value for the layer
            [self.layer setAffineTransform:CGAffineTransformMakeRotation([((CABasicAnimation *) [animations objectAtIndex:1]).toValue floatValue])];
        }
        
    }
    else{
        // anim is a single animation (position)
        self.layer.position = [((CABasicAnimation *)anim).toValue CGPointValue];
    }
    
}



- (void)setMapView:(MKMapView *)map
{
    _mapView = map;
    if (self.annotation && _mapView) {
        [self updateTransformsFromAnnotation:(HGMovingAnnotation*) self.annotation animated:NO];
    }
}

- (void)mapView :(MKMapView *)mapView didChangeZoomScale:(MKZoomScale)zoomScale
{
    
    CGFloat width = 20;
    if (zoomScale <= 16) {
        width = 28;
    }
    else if (zoomScale <= 32) {
        width = 25;
    }
    else if (zoomScale <= 64) {
        width = 20;
    }
    else if (zoomScale <= 128) {
        width = 15;
    }
    else if (zoomScale <= 256) {
        width = 10;
    }
    
    if (width != self.bounds.size.width) {
        [self setBounds:CGRectMake(0, 0, width, width) animated:YES];
    }
    
}

- (void)setBounds:(CGRect)rect animated :(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bounds = rect;
        }];
    }
    self.bounds = rect;
    
}




@end
