#import "SCISymbol.h"

@interface SCISymbol ()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) UIColor *color;
@property (nonatomic, readwrite) CGFloat size;
@property (nonatomic, readwrite) UIImageSymbolWeight weight;

- (instancetype)init;

@end

///

@implementation SCISymbol

// MARK: - Instance methods

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.name = @"";
        self.color = [UIColor labelColor];
        self.weight = UIImageSymbolWeightRegular;
        self.size = 15.0;
    }
    
    return self;
}

- (UIImage *)image {
    UIImage *symbol = [UIImage systemImageNamed:self.name];
    
    if (self.size || (self.size && self.weight)) {
        UIImageSymbolConfiguration *symbolConfig = [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleTitle1];
        symbolConfig = [symbolConfig configurationByApplyingConfiguration:
                        [UIImageSymbolConfiguration configurationWithPointSize:self.size weight:self.weight]];
        
        return [symbol imageWithConfiguration:symbolConfig];
    }
    
    return symbol;
}

// MARK: - Class methods

+ (instancetype)symbolWithName:(NSString *)name {
    SCISymbol *symbol = [[self alloc] init];
    
    symbol.name = name;

    return symbol;
}

+ (instancetype)symbolWithName:(NSString *)name color:(UIColor *)color {
    SCISymbol *symbol = [[self alloc] init];
    
    symbol.name = name;
    symbol.color = color;

    return symbol;
}

+ (instancetype)symbolWithName:(NSString *)name color:(UIColor *)color size:(CGFloat)size {
    SCISymbol *symbol = [[self alloc] init];
    
    symbol.name = name;
    symbol.color = color;
    symbol.size = size;
    
    return symbol;
}

+ (instancetype)symbolWithName:(NSString *)name color:(UIColor *)color size:(CGFloat)size weight:(UIImageSymbolWeight)weight {
    SCISymbol *symbol = [[self alloc] init];
    
    symbol.name = name;
    symbol.color = color;
    symbol.size = size;
    symbol.weight = weight;
    
    return symbol;
}

@end
