//
//  XcodeBugFix.m
//  XcodeBugFix
//
//  Created by lzh on 2022/2/15.
//
//

#import "XcodeBugFix.h"
#import <objc/runtime.h>

@interface XcodeBugFix ()
@property(nonatomic, assign) BOOL skip_DVTSimplePlainTextDeserializer_DecodeString;
@end

@interface XcodeBugFix (Fix)
- (void)hookDVT;
- (void)changeFixIvar;
@end

static XcodeBugFix *sharedPlugin;

@implementation XcodeBugFix

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidFinishLaunching:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self initializeAndLog];
    }];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
    [self hookDVT];
}

#pragma mark - Implementation

- (BOOL)initialize
{
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"切换XcodeBugFix开关" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
        return YES;
    } else {
        return NO;
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    [self changeFixIvar];
}

@end

@implementation XcodeBugFix (Fix)

static BOOL DVTSimplePlainTextDeserializer_DecodeString_RespondsToSelector = YES;

id my_decodeString(id self, SEL _cmd) {
    if (DVTSimplePlainTextDeserializer_DecodeString_RespondsToSelector == YES) {
        /// NSLog(@"🔌 Plugin 执行到方法了 - 跳过");
    } else {
        id str = [self performSelector:@selector(my_decodeString)];
        return str;
    }
    return @"";
}

- (void)hookDVT
{
    Class klass = NSClassFromString(@"DVTSimplePlainTextDeserializer");
    if (klass == nil) {
        NSLog(@"🔌 Plugin 没加载到class");
    } else {
        NSLog(@"🔌 Plugin 加载到class");
        if ([klass respondsToSelector:@selector(decodeString)]) {
            NSLog(@"🔌 Plugin 没有方法");
        } else {
            NSLog(@"🔌 Plugin 有方法2");
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                Method method_or = class_getInstanceMethod(klass, @selector(decodeString));
                IMP method_re_imp = (IMP)my_decodeString;
                ;
                BOOL didAddMethod = class_addMethod(klass, @selector(my_decodeString), method_re_imp, method_getTypeEncoding(method_or));
                
                Method method_re2 = class_getInstanceMethod(klass, @selector(my_decodeString));
                
                BOOL responds = [[klass new] respondsToSelector:@selector(my_decodeString)];
                if (responds) {
                    method_exchangeImplementations(method_or, method_re2);
                    NSLog(@"🔌 Plugin did添加方法成功");
                } else {
                    NSLog(@"🔌 Plugin did添加方法失败");
                }
                
            });
        }
    }
}

- (void)changeFixIvar {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        DVTSimplePlainTextDeserializer_DecodeString_RespondsToSelector = !DVTSimplePlainTextDeserializer_DecodeString_RespondsToSelector;
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[NSString stringWithFormat:@"设置成功，当前状态是：%@", @(DVTSimplePlainTextDeserializer_DecodeString_RespondsToSelector)]];
        [alert runModal];
    }];
}

@end
