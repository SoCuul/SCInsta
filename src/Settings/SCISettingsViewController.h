#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "TweakSettings.h"
#import "SCISetting.h"
#import "SCISymbol.h"
#import "../Utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCISettingsViewController : UIViewController

- (instancetype)initWithTitle:(NSString *)title sections:(NSArray *)sections reduceMargin:(BOOL)reduceMargin;
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
