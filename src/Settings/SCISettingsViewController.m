#import "SCISettingsViewController.h"

static char defaultsKeyStaticRef[] = "defaultsKey";

@interface SCISettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *sections;
@property (nonatomic) BOOL reduceMargin;

@end

///

@implementation SCISettingsViewController

- (instancetype)initWithTitle:(NSString *)title sections:(NSArray *)sections reduceMargin:(BOOL)reduceMargin {
    self = [super init];
    
    if (self) {
        self.title = title;
        self.sections = sections;
        self.reduceMargin = reduceMargin;
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithTitle:[SCITweakSettings title] sections:[SCITweakSettings sections] reduceMargin:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.prefersLargeTitles = NO;
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(self.reduceMargin ? -30 : -10, 0, 0, 0);
    self.tableView.delegate = self;

    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SCISetting *row = self.sections[indexPath.section][@"rows"][indexPath.row];
    if (!row) return nil;
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UIListContentConfiguration *cellContentConfig = cell.defaultContentConfiguration;
    
    cellContentConfig.text = row.title;
    
    // Subtitle
    if (row.subtitle.length) {
        cellContentConfig.secondaryText = row.subtitle;
        cellContentConfig.textToSecondaryTextVerticalPadding = 4.5;
    }
    
    // Icon
    if (row.icon != nil) {
        cellContentConfig.image = [row.icon image];
        cellContentConfig.imageProperties.tintColor = row.icon.color;
    }
    
    // Image url
    if (row.imageUrl != nil) {
        [self loadImageFromURL:row.imageUrl atIndexPath:indexPath forTableView:tableView];
        
        cellContentConfig.imageToTextPadding = 14;
    }
    
    switch (row.type) {
        case SCITableCellStatic: {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
            
        case SCITableCellLink: {
            cellContentConfig.textProperties.color = [UIColor systemBlueColor];
            cellContentConfig.textProperties.font = [UIFont systemFontOfSize:[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize
                                                                      weight:UIFontWeightMedium];
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"safari"]];
            imageView.tintColor = [UIColor systemGray3Color];
            cell.accessoryView = imageView;
            
            break;
        }
            
        case SCITableCellSwitch: {
            UISwitch *toggle = [UISwitch new];
            toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:row.defaultsKey];
            toggle.onTintColor = [SCIUtils SCIColor_Primary];
            
            objc_setAssociatedObject(toggle, defaultsKeyStaticRef, row.defaultsKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            [toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            cell.accessoryView = toggle;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
            
        case SCITableCellStepper: {
            UIStepper *stepper = [UIStepper new];
            stepper.minimumValue = row.min;
            stepper.maximumValue = row.max;
            stepper.stepValue = row.step;
            stepper.value = [[NSUserDefaults standardUserDefaults] doubleForKey:row.defaultsKey];
            
            objc_setAssociatedObject(stepper, defaultsKeyStaticRef, row.defaultsKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            [stepper addTarget:self
                        action:@selector(stepperChanged:)
              forControlEvents:UIControlEventValueChanged];
            
            // Template subtitle
            if (row.subtitle.length) {
                cellContentConfig.secondaryText = [self formatString:row.subtitle withValue:stepper.value label:row.label singularLabel:row.singularLabel];
            }
            
            cell.accessoryView = stepper;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
            
        case SCITableCellButton: {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
            
        case SCITableCellNavigation: {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
    }
    
    cell.contentConfiguration = cellContentConfig;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section][@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section][@"title"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.sections[section][@"footer"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SCISetting *row = self.sections[indexPath.section][@"rows"][indexPath.row];
    if (!row) return;

    if (row.type == SCITableCellLink) {
        [[UIApplication sharedApplication] openURL:row.url options:@{} completionHandler:nil];
    }
    if (row.type == SCITableCellButton) {
        if (row.action != nil) {
            row.action();
        }
    }
    else if (row.type == SCITableCellNavigation) {
        if (row.navSections.count > 0) {
            UIViewController *vc = [[SCISettingsViewController alloc] initWithTitle:row.title sections:row.navSections reduceMargin:NO];
            vc.title = row.title;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (void)switchChanged:(UISwitch *)sender {
    NSString *defaultsKey = objc_getAssociatedObject(sender, defaultsKeyStaticRef);
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:defaultsKey];
    
    NSLog(@"Switch changed: %@", sender.isOn ? @"ON" : @"OFF");
}

- (void)stepperChanged:(UIStepper *)sender {
    NSString *defaultsKey = objc_getAssociatedObject(sender, defaultsKeyStaticRef);
    [[NSUserDefaults standardUserDefaults] setDouble:sender.value forKey:defaultsKey];
    
    NSLog(@"Stepper changed: %f", sender.value);
    
    [self reloadCellForView:sender];
}

#pragma mark - Helper

- (NSString *)formatString:(NSString *)template withValue:(double)value label:(NSString *)label singularLabel:(NSString *)singularLabel {
    // Singular or plural labels
    NSString *applicableLabel = fabs(value - 1.0) < 0.00001 ? singularLabel : label;
    
    // Force value to 0 to prevent it being -0
    if (fabs(value) < 0.00001) {
        value = 0.0;
    }

    // Get correct decimal value based on step value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = [SCIUtils decimalPlacesInDouble:value];

    NSString *stringValue = [formatter stringFromNumber:@(value)];

    return [NSString stringWithFormat:template, stringValue, applicableLabel];
}

- (void)reloadCellForView:(UIView *)view {
    UITableViewCell *cell = (UITableViewCell *)view.superview;
    while (cell && ![cell isKindOfClass:[UITableViewCell class]]) {
        cell = (UITableViewCell *)cell.superview;
    }
    if (!cell) return;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) return;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (void)loadImageFromURL:(NSURL *)url atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView
{
    if (!url) return;

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!data || error) return;

        UIImage *image = [UIImage imageWithData:data];
        if (!image) return;

        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) return;

            UIListContentConfiguration *config = (UIListContentConfiguration *)cell.contentConfiguration;
            config.image = image;
            config.imageProperties.maximumSize = CGSizeMake(45, 45);
            cell.contentConfiguration = config;
        });
    }];

    [task resume];
}

@end
