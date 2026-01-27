#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../modules/JGProgressHUD/JGProgressHUD.h"
#import "./InstagramHeaders.h"

@interface SCIUtils : NSObject

// Colours
+ (UIColor *)SCIColor_Primary;

// Errors
+ (NSError *)errorWithDescription:(NSString *)errorDesc;
+ (NSError *)errorWithDescription:(NSString *)errorDesc code:(NSInteger)errorCode;

+ (JGProgressHUD *)showErrorHUDWithDescription:(NSString *)errorDesc;
+ (JGProgressHUD *)showErrorHUDWithDescription:(NSString *)errorDesc dismissAfterDelay:(CGFloat)dismissDelay;

// Media
+ (NSURL *)getPhotoUrl:(IGPhoto *)photo;
+ (NSURL *)getPhotoUrlForMedia:(IGMedia *)media;

+ (NSURL *)getVideoUrl:(IGVideo *)video;
+ (NSURL *)getVideoUrlForMedia:(IGMedia *)media;

// View Controllers
+ (UIViewController *)viewControllerForView:(UIView *)view;
+ (UIViewController *)viewControllerForAncestralView:(UIView *)view;
+ (UIViewController *)nearestViewControllerForView:(UIView *)view;

// Functions
+ (NSString *)IGVersionString;
+ (BOOL)isNotch;

+ (BOOL)existingLongPressGestureRecognizerForView:(UIView *)view;
+ (BOOL)showConfirmation:(void(^)(void))okHandler;
+ (BOOL)showConfirmation:(void(^)(void))okHandler cancelHandler:(void(^)(void))cancelHandler;
+ (void)showRestartConfirmation;
+ (void)prepareAlertPopoverIfNeeded:(UIAlertController*)alert inView:(UIView*)view;

// Math
+ (NSUInteger)decimalPlacesInDouble:(double)value;

@end