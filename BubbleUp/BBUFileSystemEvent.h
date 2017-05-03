//
//  BBUFileSystemEvent.h
//  BubbleUp
//
//  Created by Roben Kleene on 11/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface BBUFileSystemEvent : NSObject
+ (instancetype)fileSystemEventWithPath:(NSString *)path
                             eventFlags:(FSEventStreamEventFlags)eventFlags
                                eventId:(FSEventStreamEventId)eventId;
@property (nonatomic, strong) NSString *path;
- (BOOL)itemWasCreated;
- (BOOL)itemWasModified;
- (BOOL)itemWasRemoved;
- (BOOL)itemWasRenamed;
- (BOOL)itemIsFile;
- (BOOL)itemIsDirectory;
@end
NS_ASSUME_NONNULL_END
