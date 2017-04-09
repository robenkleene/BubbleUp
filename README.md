# BubbleUp

A simple Cocoa Wrapper for macOS [File System Events API](https://developer.apple.com/library/content/documentation/Darwin/Conceptual/FSEvents_ProgGuide/UsingtheFSEventsFramework/UsingtheFSEventsFramework.html).

``` objective-c
NS_ASSUME_NONNULL_BEGIN
@protocol WCLDirectoryWatcherDelegate <NSObject>
@optional
- (void)directoryWatcher:(WCLDirectoryWatcher *)directoryWatcher directoryWasCreatedOrModifiedAtPath:(NSString *)path;
- (void)directoryWatcher:(WCLDirectoryWatcher *)directoryWatcher fileWasCreatedOrModifiedAtPath:(NSString *)path;
- (void)directoryWatcher:(WCLDirectoryWatcher *)directoryWatcher itemWasRemovedAtPath:(NSString *)path;
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface WCLDirectoryWatcher : NSObject
- (id)initWithURL:(NSURL *)url;
@property (nonatomic, weak, nullable) id<WCLDirectoryWatcherDelegate> delegate;
@end
NS_ASSUME_NONNULL_END
```

Install with [Carthage/Carthage: A simple, decentralized dependency manager for Cocoa](https://github.com/Carthage/Carthage).

