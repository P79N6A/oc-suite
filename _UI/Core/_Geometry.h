// inspired by https://github.com/mysterioustrousers/MTGeometry/blob/master/MTGeometry/MTGeometry.c

#import <math.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#define NULL_NUMBER         INFINITY
#define NULL_POINT          CGPointMake(NULL_NUMBER, NULL_NUMBER)
#define RADIANS(degrees)    ((degrees * M_PI) / 180.0)


// A delta point representing the distance of a translation transform
typedef CGPoint CGDelta;

// A line is defined as two points
typedef struct {
    CGPoint point1;
    CGPoint point2;
} CGLine;

// A circle is defined as a center point and a radius
typedef struct {
    CGPoint center;
    CGFloat radius;
} CGCircle;


#pragma mark - Points

// Create a delta from a delta x and y
CGDelta CGDeltaMake(CGFloat deltaX, CGFloat deltaY);

// Get the distance between two points
CGFloat	CGPointDistance(CGPoint p1, CGPoint p2);

// A point along a line distance from point1.
CGPoint CGPointAlongLine(CGLine line, CGFloat distance);

// A point rotated around the pivot point by degrees.
CGPoint CGPointRotatedAroundPoint(CGPoint point, CGPoint pivot, CGFloat degrees);


#pragma mark - Lines

// Create a line from 2 points.
CGLine CGLineMake(CGPoint point1, CGPoint point2);

// Returns true if two lines are exactly coincident
bool CGLineEqualToLine(CGLine line1, CGLine line2);

// Get a lines midpoint
CGPoint CGLineMidPoint(CGLine line);

// Get the point at which two lines intersect. Returns NULL_POINT if they don't intersect.
CGPoint CGLinesIntersectAtPoint(CGLine line1, CGLine line2);

// Get the length of a line
CGFloat CGLineLength(CGLine line);

// Returns a scaled line. Point 1 acts as the base and Point 2 is extended.
CGLine CGLineScale(CGLine line, CGFloat scale);

// Returns a line translated by delta.
CGLine CGLineTranslate(CGLine line, CGDelta delta);

// Returns a scaled line with the same midpoint.
CGLine CGLineScaleOnMidPoint(CGLine line, CGFloat scale);

// Returns the delta x and y of the line from point 1 to point 2.
CGDelta CGLineDelta(CGLine line);

// Returns true if two lines are parallel
bool CGLinesAreParallel(CGLine line1, CGLine line2);

#pragma mark - Rectangles

// Corners points of a CGRect
CGPoint CGRectTopLeftPoint(CGRect rect);
CGPoint CGRectTopRightPoint(CGRect rect);
CGPoint CGRectBottomLeftPoint(CGRect rect);
CGPoint CGRectBottomRightPoint(CGRect rect);

// Returns a resized rect with the same centerpoint.
CGRect	CGRectResize(CGRect rect, CGSize newSize);

// Similar to CGRectInset but only insets one edge. All other edges do not move.
CGRect	CGRectInsetEdge(CGRect rect, CGRectEdge edge, CGFloat amount);

/**
 Calculates the stacking of rectangles within a larger rectangle.
 The resulting rectangle is stacked counter clockwise along the edge specified. As soon as
 there are more rects than will fit, a new row is started, thus, they are stacked by column,
 then by row. `reverse` will cause them to be stacked counter-clockwise along the specified edge.
 */
CGRect	CGRectStackedWithinRectFromEdge(CGRect rect, CGSize size, int count, CGRectEdge edge, bool reverse);

// Find the centerpoint of a rectangle.
CGPoint _CGRectCenterPoint(CGRect rect); // @fallenink: 居然和微博sdk里面冲突，SDK开发中，一定是需要特殊前缀的。

// Assigns the closest two corner points to point1 and point2 of the rect to the passed in point.
void	CGRectClosestTwoCornerPoints(CGRect rect, CGPoint point, CGPoint *point1, CGPoint *point2);

// The point at which a line, extended infinitely past its second point, intersects
// the rectangle. Returns NULL_POINT if no interseciton is found.
CGPoint CGLineIntersectsRectAtPoint(CGRect rect, CGLine line);


// inspired by https://github.com/kreeger/BDKGeometry/blob/master/BDKGeometry.h

/** Gives a rect a new origin.
 *  @param rect the rect on which to operate.
 *  @param origin a new origin CGPoint to assign to `rect`.
 *  @return a new rect with the given origin.
 */
CGRect CGRectSetOrigin(CGRect rect, CGPoint origin);

/** Gives a rect's size a new width.
 *  @param rect the rect on which to operate.
 *  @param width a new width CGFloat to assign to `rect`.
 *  @return a new rect with the given width.
 */
CGRect CGRectSetWidth(CGRect rect, CGFloat width);

/** Gives a rect a new height.
 *  @param rect the rect on which to operate.
 *  @param height a new height CGFloat to assign to `rect`.
 *  @return a new rect with the given height.
 */
CGRect CGRectSetHeight(CGRect rect, CGFloat height);

/** Gives a rect a new y-origin.
 *  @param rect the rect on which to operate.
 *  @param yOrigin a new y-origin CGFloat to assign to `rect`.
 *  @return a new rect with the given y-origin.
 */
CGRect CGRectSetYOrigin(CGRect rect, CGFloat yOrigin);


/** Gives a rect a new x-origin.
 *  @param rect the rect on which to operate.
 *  @param xOrigin a new x-origin CGFloat to assign to `rect`.
 *  @return a new rect with the given x-origin.
 */
CGRect CGRectSetXOrigin(CGRect rect, CGFloat xOrigin);

/** Centers a child (sub) rect inside of a parent (master) rect, using both width and height.
 *  @param subRect the child rect, which will be altered and returned.
 *  @param masterRect the parent rect in which to center `subRect`.
 *  @return the modified `subRect`.
 */
CGRect CGRectCenterRectInRect(CGRect subRect, CGRect masterRect);

/** Centers a child (sub) rect inside of a parent (master) rect horizontally (only modifies x-origin).
 *  @param subRect the child rect, which will be altered and returned.
 *  @param masterRect the parent rect in which to center `subRect` horizontally.
 *  @return the modified `subRect`.
 */
CGRect CGRectCenterRectInRectHorizontally(CGRect subRect, CGRect masterRect);

/** Centers a child (sub) rect inside of a parent (master) rect vertically (only modifies y-origin).
 *  @param subRect the child rect, which will be altered and returned.
 *  @param masterRect the parent rect in which to center `subRect` vertically.
 *  @return the modified `subRect`.
 */
CGRect CGRectCenterRectInRectVertically(CGRect subRect, CGRect masterRect);

/** Calls `CGRectInset` on a given rect, and multiplies inset by the percentage given for both width and height.
 *  @param rect the rect which will be altered and returned.
 *  @param xPercent the percentage by which to multiply the `rect`'s width.
 *  @param yPercent the percentage by which to multiply the `rect`'s height.
 *  @return the modified `rect`.
 */
CGRect CGRectInsetByPercent(CGRect rect, CGFloat xPercent, CGFloat yPercent);

/** Uses `CGRectDivide` and disposes the remainder.
 *  @param rect the rect which will be altered and returned.
 *  @param amount the amount to trim off.
 *  @param edge the edge to trim from.
 *  @return the modified `rect`.
 */
CGRect CGRectSubtract(CGRect rect, CGFloat amount, CGRectEdge edge);

/** Modifies a given view's frame by calling `-[UIView sizeToFit]` on itself, and then ensuring it's integral by
 *  calling `CGRectIntegral` on the view's new frame.
 *  @param view the view on which to operate.
 */
void CGRectIntegralSizeToFit(UIView *view);

/** Doubles the size of a given size by multiplying width and height by a factor of 2.
 *  @param size the size to double.
 *  @return a new doubled size.
 */
CGSize CGSizeByDoubling(CGSize size);

/** Doubles the size of a given rect by multiplying width and height by a factor of 2, keeping the same origin.
 *  @param rect the rect whose size to double.
 *  @return a new doubled-size rect.
 */
CGRect CGRectByDoublingSize(CGRect rect);

/** Generates a rect for drawing 1-pixel lines.
 *  @param rect The rect to inset by a half pixel.
 *  @return A new rect.
 */
CGRect CGRectFor1PxStroke(CGRect rect);




#pragma mark - Arcs

// The control points for an arc from startPoint to endPoint with radius.
// To determine the right hand rule: make an arc with your right hand, placing your pinky on the screen and your
// thumb pointing out from the screen. With the base of your hand at the start point, the curvature of your hand
// indicates what direction the arc will curve to the endpoint.
void CGControlPointsForArcBetweenPointsWithRadius(CGPoint startPoint,
                                                  CGPoint endPoint,
                                                  CGFloat radius,
                                                  bool rightHandRule,
                                                  CGPoint *controlPoint1,
                                                  CGPoint *controlPoint2);



// Create a circle from a center and a radius
CGCircle CGCircleMake(CGPoint center, CGFloat radius);

// Returns true if two circles are exactly coincident
bool CGCircleEqualToCircle(CGCircle circle1, CGCircle circle2);

// Returns a scaled circle.
CGCircle CGCircleScale(CGCircle circle, CGFloat scale);

// Returns a circle translated by delta.
CGCircle CGCircleTranslate(CGCircle circle, CGDelta delta);

// Returns true if point is inside or on the boundary of the circle
bool CGCircleContainsPoint(CGCircle circle, CGPoint point);

// Returns true if two circles intersect or one is contained within the other
bool CGCircleIntersectsCircle(CGCircle circle1, CGCircle circle2);

// Returns true if circle and line intersect
bool CGCircleIntersectsLine(CGCircle circle, CGLine line);

// Returns the number of intersection points - 0, 1 or 2
int CGCircleIntersectsLineWithPoints(CGCircle circle, CGLine line, CGPoint *intersect1, CGPoint *intersect2);

// Returns true if circle and rectangle intersect
bool CGCircleIntersectsRectangle(CGCircle circle, CGRect rect);

// Returns the minimum size rectangle that contains circle
CGRect CGCircleGetBoundingRect(CGCircle circle);

// Returns the distance from a point to a circle
// Returns 0 if the point is inside the circle
CGFloat CGGetDistanceFromPointToCircle(CGPoint point, CGCircle circle);

#pragma mark -

/*** 返回被放大 scale 倍后的 rect
 * @discussion 错误返回 CGRectZero
 */
CGRect CGRectMakeScale(CGRect rect, CGFloat scale);

/*** 返回顶点为 (0,0)， 大小与frame.size 相同的矩形*/
CGRect CGRectMakeFull(CGRect frame);

/*** 返回在 r 中大小为 size，居中的矩形大小 */
CGRect CGRectCenterRectWithSize(CGRect r, CGSize size);

