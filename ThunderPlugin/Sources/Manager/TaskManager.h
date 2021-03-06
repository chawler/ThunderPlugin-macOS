//
//  TaskManager.h
//  ThunderPlugin
//
//  Created by Stanley on 2018/11/12.
//  Copyright © 2018年 Stanley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskManager : NSObject

@property (nonatomic) NSMutableArray *allTasks;
@property (nonatomic) NSMutableArray *downloadingTasks;
@property (nonatomic) NSMutableArray *completedTasks;
@property (nonatomic) NSMutableArray *deletedTasks;
@property (nonatomic) NSMutableArray *sectionCompletedTasks;

+ (TaskManager *)shared;

- (void)createTaskWithURL:(NSString *)urlString;

- (void)createBTTaskWithName:(NSString *)name btFile:(NSString *)btFile fileIndexs:(NSArray *)fileIndex;

- (NSDictionary *)torrentInfoWithMagnetURL:(NSString *)urlString;

- (NSDictionary *)torrentInfoWithFilename:(NSString *)filename path:(NSString *)torrentPath;

- (void)setOnCompletion:(NSDictionary *)info;

@end
