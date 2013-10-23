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
@property (nonatomic) CGFloat angle;

@end

@implementation HappArcView

- (id)initWithColor:(UIColor *)color angle:(CGFloat)angle {
    self = [super init];
    if (self) {
        _color = color;
        _angle = angle;
    }
    return self;
}

//- (void)drawRect:(CGRect)rect {
//    [[UIColor blackColor] setFill];
//    CGPoint center = CGPointMake(20, 20);
//    
//    
//    [[UIBezierPath bezierPathWithArcCenter:center radius:20 startAngle:1.57 endAngle:3.14 clockwise:NO] fill];
//}

// We force the background color to be whatever the color property is so that
// the background doesn't go away when this view is added to a cell that is selected.
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:self.color];
}
@end
