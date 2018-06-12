//
//  _math.m
//  Ben
//
//  Created by fallen.ink on 04/07/2017.
//  Copyright © 2017 fallen.ink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "_math.h"
#import "_pragma_push.h"

#pragma mark -

static CGFloat distanceBetweenPoints(CGPoint first, CGPoint second) {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
}

static CGFloat angleForStartPoint(CGPoint startPoint, CGPoint endPoint) {
    
    CGPoint Xpoint = CGPointMake(startPoint.x + 100, startPoint.y);
    
    CGFloat a = endPoint.x - startPoint.x;
    CGFloat b = endPoint.y - startPoint.y;
    CGFloat c = Xpoint.x - startPoint.x;
    CGFloat d = Xpoint.y - startPoint.y;
    
    CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
    
    if (startPoint.y>endPoint.y) {
        rads = -rads;
    }
    return rads;
}

#pragma mark -


// [self.layerView.layer containsPoint:point]

@implementation _math

@end

#import "_pragma_pop.h"
