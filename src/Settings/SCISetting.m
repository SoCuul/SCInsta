#import "SCISetting.h"

@interface SCISetting ()

@property (nonatomic, readwrite) SCITableCell type;

- (instancetype)initWithType:(SCITableCell)type NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

///

@implementation SCISetting

#pragma mark - - initWithType

- (instancetype)initWithType:(SCITableCell)type {
    self = [super init];
    
    if (self) {
        self.type = type;
    }
    
    return self;
}


#pragma mark - + staticCellWithTitle

+ (instancetype)staticCellWithTitle:(NSString *)title
                           subtitle:(NSString *)subtitle
                               icon:(SCISymbol *)icon
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellStatic];
    
    setting.title = title;
    setting.subtitle = subtitle;
    setting.icon = icon;

    return setting;
}

#pragma mark + linkCellWithTitle

+ (instancetype)linkCellWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             icon:(SCISymbol *)icon
                              url:(NSString *)url
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellLink];
    
    setting.title = title;
    setting.subtitle = subtitle;
    setting.icon = icon;
    setting.url = [NSURL URLWithString:url];

    return setting;
}

+ (instancetype)linkCellWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                         imageUrl:(NSString *)imageUrl
                              url:(NSString *)url
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellLink];
    
    setting.title = title;
    setting.subtitle = subtitle;
    
    setting.imageUrl = [NSURL URLWithString:imageUrl];
    setting.url = [NSURL URLWithString:url];
    
    return setting;
}

#pragma mark + switchCellWithTitle

+ (instancetype)switchCellWithTitle:(NSString *)title
                           subtitle:(NSString *)subtitle
                        defaultsKey:(NSString *)defaultsKey
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellSwitch];
    
    setting.title = title;
    setting.subtitle = subtitle;
    setting.defaultsKey = defaultsKey;
    
    return setting;
}

+ (instancetype)switchCellWithTitle:(NSString *)title
                           subtitle:(NSString *)subtitle
                        defaultsKey:(NSString *)defaultsKey
                    requiresRestart:(BOOL)requiresRestart
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellSwitch];
    
    setting.title = title;
    setting.subtitle = subtitle;
    setting.defaultsKey = defaultsKey;
    setting.requiresRestart = requiresRestart;
    
    return setting;
}

#pragma mark + stepperCellWithTitle

+ (instancetype)stepperCellWithTitle:(NSString *)title
                            subtitle:(NSString *)subtitle
                         defaultsKey:(NSString *)defaultsKey
                                 min:(double)min
                                 max:(double)max
                                step:(double)step
                               label:(NSString *)label
                       singularLabel:(NSString *)singularLabel
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellStepper];
    
    setting.title = title;
    setting.subtitle = subtitle;
    setting.defaultsKey = defaultsKey;
    
    setting.min = min;
    setting.max = max;
    setting.step = step;
    setting.label = label;
    setting.singularLabel = singularLabel;
    
    return setting;
}

#pragma mark + buttonCellWithTitle

+ (instancetype)buttonCellWithTitle:(NSString *)title
                           subtitle:(NSString *)subtitle
                               icon:(SCISymbol *)icon
                             action:(void (^)(void))action
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellButton];
    
    setting.title = title;
    setting.subtitle = subtitle;
    
    setting.icon = icon;
    setting.action = action;
    
    return setting;
}

#pragma mark + navigationCellWithTitle

+ (instancetype)navigationCellWithTitle:(NSString *)title
                               subtitle:(NSString *)subtitle
                                   icon:(SCISymbol *)icon
                            navSections:(NSArray *)navSections
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellNavigation];
    
    setting.title = title;
    setting.subtitle = subtitle;
    
    setting.icon = icon;
    setting.navSections = navSections;
    
    return setting;
}

@end
