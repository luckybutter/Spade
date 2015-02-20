//
//  UIView+Frame.m
//  Spade
//
//  Created by Matthew Canoy on 2/19/15.
//  Copyright (c) 2015 Luckybutter. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (CGFloat)y {
    return self.frame.origin.y;
}


@end