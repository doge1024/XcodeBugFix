//
//  XcodeBugFix.h
//  XcodeBugFix
//
//  Created by lzh on 2022/2/15.
//
//

#import <AppKit/AppKit.h>

@interface XcodeBugFix : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end