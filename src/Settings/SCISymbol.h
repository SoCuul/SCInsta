#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCISymbol : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) UIColor *color;
@property (nonatomic, readonly) CGFloat size;
@property (nonatomic, readonly) UIImageSymbolWeight weight;

- (UIImage *)image;

+ (instancetype)symbolWithName:(NSString *)name;
+ (instancetype)symbolWithName:(NSString *)name color:(UIColor *)color;
+ (instancetype)symbolWithName:(NSString *)name color:(UIColor *)color size:(CGFloat)size;
+ (instancetype)symbolWithName:(NSString *)name color:(UIColor *)color size:(CGFloat)size weight:(UIImageSymbolWeight)weight;

@end

NS_ASSUME_NONNULL_END
