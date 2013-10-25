//
//  HappArcView.m
//  Happ
//
//  Created by Brandon Krieger on 10/21/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappArcView.h"

@interface HappArcView()

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *alphaColor;
@property (nonatomic) CGFloat percentOfCircle;

@end

@implementation HappArcView

- (id)initWithColor:(UIColor *)color percentOfCircle:(CGFloat)percentOfCircle {
    self = [super init];
    if (self) {
        _color = color;
        _alphaColor = [color colorWithAlphaComponent:.3f];
        _percentOfCircle = percentOfCircle;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    // Draw outer circle with arc
    CGFloat radius = self.frame.size.width / 2;
    CGFloat startPosition = -M_PI_2; // north of circle
    CGFloat endPosition = startPosition - (self.percentOfCircle * 2 * M_PI);  // startime minus the amount of circle in radians
    CGPoint center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    UIBezierPath *arc = [UIBezierPath bezierPath]; //empty path
    [arc moveToPoint:center];
    CGPoint next;
    next.x = center.x + radius * cos(startPosition);
    next.y = center.y + radius * sin(startPosition);
    [arc addLineToPoint:next]; //go one end of arc
    [arc addArcWithCenter:center radius:radius startAngle:startPosition endAngle:endPosition clockwise:NO]; //add the arc
    [arc addLineToPoint:center]; //back to center
    [self.color set];
    [arc fill];
    
    // Draw inner circle to cover missing part of pie
    radius = (self.frame.size.width / 2) - 6;
    startPosition = 0;
    endPosition = M_PI * 2; // full circle
    arc = [UIBezierPath bezierPath]; //empty path
    [arc moveToPoint:center];
    next.x = center.x + radius * cos(startPosition);
    next.y = center.y + radius * sin(startPosition);
    [arc addLineToPoint:next];
    [arc addArcWithCenter:center radius:radius startAngle:startPosition endAngle:endPosition clockwise:NO];
    [arc addLineToPoint:center];
    [self.color set];
    [arc fill];
}

// We force the background color to be whatever the color property is so that
// the background doesn't go away when this view is added to a cell that is selected.
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:self.alphaColor];
}
@end
