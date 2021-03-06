//
//  XLCreateBTTaskWindowController+hook.m
//  ThunderPlugin
//
//  Created by Stanley on 2018/11/10.
//  Copyright © 2018年 Stanley. All rights reserved.
//

#import "XLCreateBTTaskWindowController+hook.h"
#import "WDHelper.h"

@implementation NSObject (XLCreateBTTaskWindowController)

+ (void)hookCreateBTTask {
    
    wd_hookMethod(objc_getClass("XLCreateBTTaskWindowController"), @selector(openTorrent:), [self class], @selector(hook_openTorrent:));
    
    wd_hookMethod(objc_getClass("XLCreateBTTaskWindowController"), @selector(subBTFileInfos), [self class], @selector(hook_subBTFileInfos));
    
    wd_hookMethod(objc_getClass("XLCreateBTTaskWindowController"), @selector(setSubBTFileInfos:), [self class], @selector(hook_setSubBTFileInfos:));
    
//    wd_hookMethod(objc_getClass("XLCreateBTTaskWindowController"), @selector(windowDidLoad), [self class], @selector(hook_windowDidLoad));
    
}

//- (void)hook_windowDidLoad {
//    NSLog(@"hook_windowDidLoad");
//    [self hook_windowDidLoad];
//}

- (id)hook_subBTFileInfos {
    NSLog(@"hook_subBTFileInfos");
    return [self hook_subBTFileInfos];
}

- (void)hook_setSubBTFileInfos:(id)arg1 {
    NSLog(@"hook_setSubBTFileInfos");
    [self hook_setSubBTFileInfos:arg1];
}

// 打开bt文件或者磁链链接下载完成时调用
- (void)hook_openTorrent:(id)arg1 {
    NSLog(@"hook_openTorrent");
    [self hook_openTorrent:arg1];
}

@end
