//
//  SXTableView.h
//  DSYM_ ANALYZE
//
//  Created by Sunny on 16/7/8.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol NSTableViewDragFileDelegate;

@interface SXTableView : NSTableView

@property (nonatomic , weak , nullable) id <NSTableViewDragFileDelegate> dragFileDelegate;

@end

@protocol NSTableViewDragFileDelegate <NSObject>

- (void)draggedFileFinish:(nonnull NSArray *)fileInfos;

@end