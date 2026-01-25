#import <Foundation/Foundation.h>
#import "SCISetting.h"
#import "SCISymbol.h"
#import "../Utils.h"
#import "../Tweak.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCITweakSettings : NSObject

+ (NSArray *)sections;
+ (NSString *)title;

@end

NS_ASSUME_NONNULL_END
