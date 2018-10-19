# BubbleUp [![Build Status](https://travis-ci.org/robenkleene/BubbleUp.svg?branch=master)](https://travis-ci.org/robenkleene/BubbleUp)

A simple Cocoa Wrapper for macOS [File System Events API](https://developer.apple.com/library/content/documentation/Darwin/Conceptual/FSEvents_ProgGuide/UsingtheFSEventsFramework/UsingtheFSEventsFramework.html).

``` objective-c
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
```

Install with [Carthage](https://github.com/Carthage/Carthage).

