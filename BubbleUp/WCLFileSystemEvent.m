//
//  WCLFileSystemEvent.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFileSystemEvent.h"

#pragma mark - NSStringFromFSEventStreamFlag

static inline NSString *NSStringFromFSEventStreamFlag(int flag) {
    switch (flag) {
        case kFSEventStreamEventFlagNone:
            return @"kFSEventStreamEventFlagNone";
            break;
        case kFSEventStreamEventFlagMustScanSubDirs:
            return @"kFSEventStreamEventFlagMustScanSubDirs";
            break;
        case kFSEventStreamEventFlagUserDropped:
            return @"kFSEventStreamEventFlagUserDropped";
            break;
        case kFSEventStreamEventFlagKernelDropped:
            return @"kFSEventStreamEventFlagKernelDropped";
            break;
        case kFSEventStreamEventFlagEventIdsWrapped:
            return @"kFSEventStreamEventFlagEventIdsWrapped";
            break;
        case kFSEventStreamEventFlagHistoryDone:
            return @"kFSEventStreamEventFlagHistoryDone";
            break;
        case kFSEventStreamEventFlagRootChanged:
            return @"kFSEventStreamEventFlagRootChanged";
            break;
        case kFSEventStreamEventFlagMount:
            return @"kFSEventStreamEventFlagMount";
            break;
        case kFSEventStreamEventFlagUnmount:
            return @"kFSEventStreamEventFlagUnmount";
            break;
        case kFSEventStreamEventFlagItemCreated:
            return @"kFSEventStreamEventFlagItemCreated";
            break;
        case kFSEventStreamEventFlagItemRemoved:
            return @"kFSEventStreamEventFlagItemRemoved";
            break;
        case kFSEventStreamEventFlagItemInodeMetaMod:
            return @"kFSEventStreamEventFlagItemInodeMetaMod";
            break;
        case kFSEventStreamEventFlagItemRenamed:
            return @"kFSEventStreamEventFlagItemRenamed";
            break;
        case kFSEventStreamEventFlagItemModified:
            return @"kFSEventStreamEventFlagItemModified";
            break;
        case kFSEventStreamEventFlagItemFinderInfoMod:
            return @"kFSEventStreamEventFlagItemFinderInfoMod";
            break;
        case kFSEventStreamEventFlagItemChangeOwner:
            return @"kFSEventStreamEventFlagItemChangeOwner";
            break;
        case kFSEventStreamEventFlagItemXattrMod:
            return @"kFSEventStreamEventFlagItemXattrMod";
            break;
        case kFSEventStreamEventFlagItemIsFile:
            return @"kFSEventStreamEventFlagItemIsFile";
            break;
        case kFSEventStreamEventFlagItemIsDir:
            return @"kFSEventStreamEventFlagItemIsDir";
            break;
        case kFSEventStreamEventFlagItemIsSymlink:
            return @"kFSEventStreamEventFlagItemIsSymlink";
            break;
        case kFSEventStreamEventFlagOwnEvent:
            return @"kFSEventStreamEventFlagOwnEvent";
            break;
        default:
            NSCAssert(NO, @"Invalid CMDownloadRequestTypeManifestCheck");
            return @"None";
            break;
    }
}

static inline NSString *NSStringFromFSEventFlags(FSEventStreamEventFlags eventFlags) {
    int event_stream_flags_array[21] = {
        kFSEventStreamEventFlagNone,
        kFSEventStreamEventFlagMustScanSubDirs,
        kFSEventStreamEventFlagUserDropped,
        kFSEventStreamEventFlagKernelDropped,
        kFSEventStreamEventFlagEventIdsWrapped,
        kFSEventStreamEventFlagHistoryDone,
        kFSEventStreamEventFlagRootChanged,
        kFSEventStreamEventFlagMount,
        kFSEventStreamEventFlagUnmount,
        kFSEventStreamEventFlagItemCreated,
        kFSEventStreamEventFlagItemRemoved,
        kFSEventStreamEventFlagItemInodeMetaMod,
        kFSEventStreamEventFlagItemRenamed,
        kFSEventStreamEventFlagItemModified,
        kFSEventStreamEventFlagItemFinderInfoMod,
        kFSEventStreamEventFlagItemChangeOwner,
        kFSEventStreamEventFlagItemXattrMod,
        kFSEventStreamEventFlagItemIsFile,
        kFSEventStreamEventFlagItemIsDir,
        kFSEventStreamEventFlagItemIsSymlink,
        kFSEventStreamEventFlagOwnEvent
    };
    int event_stream_flags_array_size = sizeof(event_stream_flags_array) / sizeof(int);

    NSMutableString *flags;
    for (int i = 0; i < event_stream_flags_array_size; i++) {
        int eventFlag = event_stream_flags_array[i];
        if ((eventFlags & eventFlag) == eventFlag) {
            if (!flags) {
                flags = [NSMutableString string];
            } else {
                [flags appendString:@", "];
            }
            NSString *flagName = NSStringFromFSEventStreamFlag(eventFlag);
            [flags appendString:flagName];
        }
    }
    
    return flags;
}



#pragma mark - WCLFileSystemEvent

@interface WCLFileSystemEvent ()
@property (nonatomic, assign) FSEventStreamEventId eventId;
@property (nonatomic, assign) FSEventStreamEventFlags eventFlags;
@end

@implementation WCLFileSystemEvent

+ (instancetype)fileSystemEventWithPath:(NSString *)path
                             eventFlags:(FSEventStreamEventFlags)eventFlags
                             eventId:(FSEventStreamEventId)eventId
{
    return [[WCLFileSystemEvent alloc] initWithPath:path
                                         eventFlags:eventFlags
                                            eventId:eventId];
}

- (id)initWithPath:(NSString *)path
        eventFlags:(FSEventStreamEventFlags)eventFlags
           eventId:(FSEventStreamEventId)eventId
{
    self = [super init];
    if (self) {
        _path = path;
        _eventFlags = eventFlags;
        _eventId = eventId;
    }
    return self;
}

#pragma mark - Event Type

- (BOOL)itemWasCreated
{
    return [self containsEventFlag:kFSEventStreamEventFlagItemCreated];
}

- (BOOL)itemWasModified
{
    return [self containsEventFlag:kFSEventStreamEventFlagItemModified];
}

- (BOOL)itemWasRemoved
{
    return [self containsEventFlag:kFSEventStreamEventFlagItemRemoved];
}

- (BOOL)itemWasRenamed
{
    return [self containsEventFlag:kFSEventStreamEventFlagItemRenamed];
}

- (BOOL)itemIsFile
{
    return [self containsEventFlag:kFSEventStreamEventFlagItemIsFile];
}

- (BOOL)itemIsDirectory
{
    return [self containsEventFlag:kFSEventStreamEventFlagItemIsDir];
}

- (BOOL)containsEventFlag:(int)eventFlag
{
    return (self.eventFlags & eventFlag) == eventFlag;
}



#pragma mark - Description

- (NSString *)description
{
    NSMutableString *descriptionExtension = [NSMutableString string];
    
    [descriptionExtension appendFormat:@"; self.path = %@", self.path];
    [descriptionExtension appendFormat:@"; eventId = %llu", self.eventId];
    NSString *flags = NSStringFromFSEventFlags(self.eventFlags);
    [descriptionExtension appendFormat:@"; flags = %@", flags];

    return [[super description] stringByAppendingString:descriptionExtension];
}

@end
