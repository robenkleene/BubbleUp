//
//  WCLDirectoryWatcher.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLDirectoryWatcher.h"
#import "WCLFileSystemEvent.h"

#pragma mark - WCLDirectoryWatcher Class Extension

@interface WCLDirectoryWatcher ()
@property (nonatomic, assign) FSEventStreamRef stream;
- (void)handleFileSystemEvent:(WCLFileSystemEvent *)fileSystemEvent;
@end


#pragma mark - C

void wcl_plugin_directory_event_stream_callback(ConstFSEventStreamRef streamRef,
                                                void *clientCallBackInfo,
                                                size_t numEvents,
                                                void *eventPaths,
                                                const FSEventStreamEventFlags eventFlags[],
                                                const FSEventStreamEventId eventIds[])
{
    WCLDirectoryWatcher *directoryWatcher = (__bridge WCLDirectoryWatcher *)clientCallBackInfo;
    int i;
    char **paths = eventPaths;
    for (i = 0; i < numEvents; i++) {
        NSString *path = [NSString stringWithFormat:@"%s", paths[i]];
        WCLFileSystemEvent *fileSystemEvent = [WCLFileSystemEvent fileSystemEventWithPath:path
                                                                               eventFlags:eventFlags[i]
                                                                                  eventId:eventIds[i]];
        [directoryWatcher handleFileSystemEvent:fileSystemEvent];
    }
}


#pragma mark - WCLDirectoryWatcher Implementation

@implementation WCLDirectoryWatcher

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        [self watchURL:url];
    }
    return self;
}

- (void)handleFileSystemEvent:(WCLFileSystemEvent *)fileSystemEvent
{
//    NSLog(@"%@ fileSystemEvent = %@", self, fileSystemEvent);

    NSString *path = fileSystemEvent.path;
    
    // File system events are simplified into to possible events:
    // 1. A file was created or modified
    // 2. A file was removed
    // More granularity is not possible because FSEvent flags are cumulative since
    // the path was started being watched.
    // If a file is renamed, two events are triggered, both with the renamed flag
    // 1. For the original file
    // 2. For the new file
    // Therefore a rename event can either be a remove or create/modify
    
    BOOL isDir = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (([fileSystemEvent itemWasRemoved] ||
         [fileSystemEvent itemWasRenamed]) &&
        !fileExists) {
        // We can't distinguish between files and directories being removed since flags are cumulative.
        // If a file was replace at a path that once had a directory, or vice versa, then the file system
        // event will have both flags.
        if ([self.delegate respondsToSelector:@selector(directoryWatcher:itemWasRemovedAtPath:)]) {
            [self.delegate directoryWatcher:self itemWasRemovedAtPath:path];
        }
    } else if (([fileSystemEvent itemWasCreated] ||
                [fileSystemEvent itemWasModified] ||
                [fileSystemEvent itemWasRenamed]) &&
               fileExists) {
        if (isDir) {
            if ([self.delegate respondsToSelector:@selector(directoryWatcher:directoryWasCreatedOrModifiedAtPath:)]) {
                [self.delegate directoryWatcher:self directoryWasCreatedOrModifiedAtPath:path];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(directoryWatcher:fileWasCreatedOrModifiedAtPath:)]) {
                [self.delegate directoryWatcher:self fileWasCreatedOrModifiedAtPath:path];
            }
        }
    }
}

- (void)watchPath:(NSString *)path
{
    CFStringRef pathRef = (__bridge CFStringRef)path;
    CFArrayRef pathsRef = CFArrayCreate(NULL,
                                        (const void **)&pathRef,
                                        1,
                                        NULL);
    FSEventStreamContext callbackInfo;
    callbackInfo.version = 0;
    callbackInfo.info = (__bridge void *)self;
    callbackInfo.retain = NULL;
    callbackInfo.release = NULL;
    callbackInfo.copyDescription = NULL;
    
    self.stream = FSEventStreamCreate(NULL,
                                      &wcl_plugin_directory_event_stream_callback,
                                      &callbackInfo,
                                      pathsRef,
                                      kFSEventStreamEventIdSinceNow,
                                      0,
                                      kFSEventStreamCreateFlagIgnoreSelf | kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(self.stream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(self.stream);
}

- (void)watchURL:(NSURL *)url
{
    [self watchPath:[url path]];
}

- (void)dealloc
{
    FSEventStreamStop(self.stream);
    FSEventStreamInvalidate(self.stream);
}

@end
