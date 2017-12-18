//
//  SXColorView.m
//  DSYM_ ANALYZE
//
//  Created by Sunny on 16/7/8.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "SXColorView.h"

@implementation SXColorView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
    {
        [self setupLayer];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        [self setupLayer];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupLayer];
}

- (void)setupLayer
{
    self.wantsLayer = YES;
    self.layer.borderColor = [NSColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1.f;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [NSGraphicsContext saveGraphicsState];
    
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    
    [self.backgroundViewColor set];
    
    [[NSBezierPath bezierPathWithRect:self.bounds] fill];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (NSColor *)backgroundViewColor
{
    if (!_backgroundViewColor) _backgroundViewColor = [NSColor clearColor];
    return _backgroundViewColor;
}

- (BOOL)isOpaque
{
    return NO;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end
