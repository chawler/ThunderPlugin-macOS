//
//  TaskManager.m
//  ThunderPlugin
//
//  Created by Stanley on 2018/11/12.
//  Copyright © 2018年 Stanley. All rights reserved.
//

#import "TaskManager.h"
#import "FKTaskModel.h"
#import "XLTaskHelper.h"
#import <objc/runtime.h>
#import "FileHelper.h"

@interface TaskManager()

@property (nonatomic, copy) void (^onMagnetCompletion)(NSDictionary *info);
@property (nonatomic, strong) NSMutableArray *downloadTorrents;

@end

@implementation TaskManager

+ (TaskManager *)shared {
    static id sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test:) name:@"XLDownloadingTaskChangedNotification" object:nil];
        self.downloadTorrents = [NSMutableArray array];
    }
    return self;
}

- (void)test:(NSNotification *)noti {
    NSLog(@"%@", noti);
}

/**
 该方法十分复杂，套了两层闭包block的值，得用dispatch_groupz阻塞线程才能拿到block中的值

 @param urlString 磁力链接
 @return 种子信息
 */
- (NSDictionary *)torrentInfoWithMagnetURL:(NSString *)urlString {
    [XLTaskHelper parseMagnet:urlString];
    dispatch_group_t taskGroup = dispatch_group_create();
    __block NSDictionary *taskInfo;
    self.onMagnetCompletion = ^(NSDictionary *info) {
        if ([info[@"DSKeyTaskInfoURL"] isEqualToString:urlString]) {
            taskInfo = info;
            dispatch_group_leave(taskGroup);
        }
    };
    dispatch_group_enter(taskGroup);
    dispatch_group_t torrentGroup = dispatch_group_create();
    __block FKTorrentModel *torrentInfo;
    __block NSString *torrentPath;
    dispatch_group_notify(taskGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        torrentPath = [taskInfo[@"DSKeyTaskInfoFilePath"] stringByAppendingPathComponent:taskInfo[@"DSKeyTaskInfoFileName"]];
        torrentInfo = [XLTaskHelper getTorrentInfo:torrentPath];
        torrentPath = [FileHelper moveFile:torrentPath to:[torrentInfo.hashValue lowercaseString]];
        dispatch_group_leave(torrentGroup);
    });
    dispatch_group_enter(torrentGroup);
    dispatch_group_wait(taskGroup, DISPATCH_TIME_FOREVER);
    dispatch_group_wait(torrentGroup, DISPATCH_TIME_FOREVER);
    @synchronized(self) {
        [self.downloadTorrents insertObject:torrentPath atIndex:0];
    }
    return [torrentInfo toDictionaryAndAddEntries:@{@"torrentPath": torrentPath}];
}

- (NSDictionary *)torrentInfoWithFilename:(NSString *)filename path:(NSString *)torrentPath {
    FKTorrentModel *torrentInfo = [XLTaskHelper getTorrentInfo:torrentPath];
    torrentPath = [FileHelper moveFile:torrentPath to:filename];
    return [torrentInfo toDictionaryAndAddEntries:@{@"torrentPath": torrentPath}];
}

- (void)createTaskWithURL:(NSString *)urlString {
    if (!urlString || [urlString isEqualToString:@""]) return;
    [XLTaskHelper createTaskWithURL:urlString];
}

- (void)createBTTaskWithName:(NSString *)name btFile:(NSString *)btFile fileIndexs:(NSArray *)fileIndex {
    if (name && [name isEqualToString:@""]) return;
    if (btFile && [btFile isEqualToString:@""]) return;
    if (fileIndex && fileIndex.count <= 0) return;
    [XLTaskHelper createBTTaskWithName:name btFile:btFile fileIndexs:fileIndex];
}

- (void)setOnCompletion:(NSDictionary *)info {
    if (self.onMagnetCompletion != nil && [info[@"DSKeyTaskInfoTaskState"] integerValue] == 3) {
        self.onMagnetCompletion(info);
    }
}

- (NSMutableArray *)allTasks {
    return [self getTasksForKeyPath:@"allTasks"];
}

- (NSMutableArray *)downloadingTasks {
    return [self getTasksForKeyPath:@"downloadingTasks"];
}

- (NSMutableArray *)completedTasks {
    return [self getTasksForKeyPath:@"completedTasks"];
}

- (NSMutableArray *)deletedTasks {
    return [self getTasksForKeyPath:@"deletedTasks"];
}

- (NSMutableArray *)sectionCompletedTasks {
    return [self getTasksForKeyPath:@"sectionCompletedTasks"];
}

- (NSMutableArray *)getTasksForKeyPath:(NSString *)keyPath {
    TasksCategoryMgr *mgr = [objc_getClass("TasksCategoryMgr") performSelector:@selector(sharedMgr)];
    NSMutableArray *newArray = [NSMutableArray array];
    for (LocalTask *item in [mgr valueForKeyPath:keyPath]) {
        [newArray addObject:[[FKTaskModel alloc] initWithLocalTask:item]];
    }
    return newArray;
}

@end
