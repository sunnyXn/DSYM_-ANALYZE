//
//  SXTableView.m
//  DSYM_ ANALYZE
//
//  Created by Sunny on 16/7/8.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "SXTableView.h"

@implementation SXTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
    {
        [self registerFordrag];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        [self registerFordrag];
    }
    return self;
}

- (void)awakeFromNib
{
    [self registerFordrag];
}

- (void)registerFordrag
{
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if (!self.dragFileDelegate) return NSDragOperationNone;
    
    if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType])
    {
        return NSDragOperationGeneric;
    }
    return NSDragOperationNone;;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    return [self draggingEntered:sender];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
        
        if ([self.dragFileDelegate respondsToSelector:@selector(draggedFileFinish:)])
        {
            NSLog(@"filenames:%@",filenames);
            if (filenames && filenames.count)
            {
                [self.dragFileDelegate performSelector:@selector(draggedFileFinish:) withObject:filenames];
            }
        }
        return YES;
    }
    return NO;
}

@end
