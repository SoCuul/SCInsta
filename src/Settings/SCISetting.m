#import "SCISetting.h"

@interface SCISetting ()

@property (nonatomic, readwrite) SCITableCell type;

- (instancetype)initWithType:(SCITableCell)type NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

///

@implementation SCISetting

// MARK: - - initWithType

- (instancetype)initWithType:(SCITableCell)type {
    self = [super init];
    
    if (self) {
        self.type = type;
    }
    
    return self;
}


// MARK: - + staticCellWithTitle

+ (instancetype)staticCellWithTitle:(NSString *)title
                           subtitle:(NSString *)subtitle
                               icon:(nullable SCISymbol *)icon
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellStatic];
    
    setting.title = title;
    setting.subtitle = subtitle;
    setting.icon = icon;

    return setting;
}

// MARK: - + linkCellWithTitle

+ (instancetype)linkCellWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             icon:(nullable SCISymbol *)icon
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

// MARK: - + switchCellWithTitle

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

// MARK: - + stepperCellWithTitle

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

// MARK: - + buttonCellWithTitle

+ (instancetype)buttonCellWithTitle:(NSString *)title
                           subtitle:(NSString *)subtitle
                               icon:(nullable SCISymbol *)icon
                             action:(void (^)(void))action
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellButton];
    
    setting.title = title;
    setting.subtitle = subtitle;
    
    setting.icon = icon;
    setting.action = action;
    
    return setting;
}

# pragma mark + menuCellWithTitle

+ (instancetype)menuCellWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             menu:(UIMenu *)menu
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellMenu];
    
    setting.title = title;
    setting.subtitle = subtitle;
    
    setting.baseMenu = menu;
    
    return setting;
}

// MARK: - + navigationCellWithTitle

+ (instancetype)navigationCellWithTitle:(NSString *)title
                               subtitle:(NSString *)subtitle
                                   icon:(nullable SCISymbol *)icon
                            navSections:(NSArray *)navSections
{
    SCISetting *setting = [[self alloc] initWithType:SCITableCellNavigation];
    
    setting.title = title;
    setting.subtitle = subtitle;
    
    setting.icon = icon;
    setting.navSections = navSections;
    
    return setting;
}


// MARK: -  Instance methods

- (UIMenu *)menuForButton:(UIButton *)button {
    return [self submenuForButton:button submenu:self.baseMenu];
}

- (UIMenu *)submenuForButton:(UIButton *)button submenu:(UIMenu*)submenu {
    NSMutableArray<UIMenuElement *> *children = [NSMutableArray array];

    for (id obj in submenu.children) {
        // Handle recursive submenus
        if ([obj isKindOfClass:[UIMenu class]]) {
            [children addObject:[self submenuForButton:button submenu:(UIMenu *)obj]];
            continue;
        }
        else if (![obj isKindOfClass:[UICommand class]]) {
            continue;
        }

        UICommand *child = obj;

        NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:child.propertyList[@"defaultsKey"]];

        UICommand *command = [UICommand commandWithTitle:child.title
                                                   image:child.image
                                                  action:child.action
                                            propertyList:child.propertyList];
        
        if ([child.propertyList[@"value"] isEqualToString:saved]) {
            command.state = YES;
            
            [button setTitle:command.title forState:UIControlStateNormal];
        }
        else {
            command.state = NO;
        }
        
        [children addObject:command];
    }

    return [UIMenu menuWithTitle:submenu.title image:nil identifier:nil options:submenu.options children:children];
}

@end
