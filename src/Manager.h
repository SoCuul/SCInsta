#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

#import "InstagramHeaders.h"
#import "QuickLook.h"

@interface SCIManager : NSObject

+ (BOOL)getBoolPref:(NSString *)key;
+ (double)getDoublePref:(NSString *)key;
+ (void)cleanCache;

// View Controllers
+ (void)showQuickLookVC:(NSArray<id> *)items;
+ (void)showShareVC:(id)item;

@end