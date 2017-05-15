//
//  BBUDirectoryWatcher.h
//  BubbleUp
//
//  Created by Roben Kleene on 11/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBUDirectoryWatcher;

NS_ASSUME_NONNULL_BEGIN
@protocol BBUDirectoryWatcherDelegate <NSObject>
@optional
- (void)directoryWatcher:(BBUDirectoryWatcher *)directoryWatcher directoryWasCreatedOrModifiedAtPath:(NSString *)path;
- (void)directoryWatcher:(BBUDirectoryWatcher *)directoryWatcher fileWasCreatedOrModifiedAtPath:(NSString *)path;
- (void)directoryWatcher:(BBUDirectoryWatcher *)directoryWatcher itemWasRemovedAtPath:(NSString *)path;
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface BBUDirectoryWatcher : NSObject
- (id)initWithURL:(NSURL *)url;
@property (nonatomic, weak, nullable) id<BBUDirectoryWatcherDelegate> delegate;
@end
NS_ASSUME_NONNULL_END
