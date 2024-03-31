#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import "../../Controllers/SettingsViewController.h"

// Workaround to show BHInsta settings by clicking on Instagram logo
%hook IGMainAppHeaderView
- (void)_logoButtonTapped {
    NSLog(@"[BHInsta] Displaying BHInsta settings modal");

    UIViewController *rootController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    SettingsViewController *settingsViewController = [SettingsViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    [rootController presentViewController:navigationController animated:YES completion:nil];

    return;
}
%end

// Legacy (as of March 13th 2023)
%hook IGProfileMenuSheetViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 8) {
        IGProfileSheetTableViewCell *bhinstacell = [[%c(IGProfileSheetTableViewCell) alloc] initWithReuseIdentifier:@"bhinsta_settings"];

        UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];
        UIImage *gear = [UIImage systemImageNamed:@"gearshape.fill" withConfiguration:configuration];

        [bhinstacell.imageView setImage:gear];
        [bhinstacell.imageView setTintColor:[UIColor labelColor]];
        [bhinstacell.textLabel setText:@" BHInsta Settings"];

        return bhinstacell;
    }

    return %orig;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 8) {
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]];
        [self _superPresentViewController:navVC animated:true completion:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:true];
    } else {
        return %orig;
    }
}
%end

// TODO: Add BHInsta settings button to profile header navbar icons
/* %hook IGStackLayout
// Display Settings Modal
%new - (void)displaySettingsModal:(id)sender {
    // Display settings modal
    NSLog(@"[BHInsta] Displaying BHInsta settings modal");

    UIViewController *rootController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    SettingsViewController *settingsViewController = [SettingsViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    [rootController presentViewController:navigationController animated:YES completion:nil];

    return;
}

// test to get icon info
- (id)initWithIcon:(id)arg1 target:(id)arg2 action:(SEL)arg3 buttonType:(NSUInteger)arg4 {
    NSLog(@"[BHInsta] Icon: %@", arg1);

    return %orig;
}

- (id)initWithChildren:(id)children {
    // Check if children contain badged icons (only used on profile page)
    BOOL containsClass = NO;

    for (id child in children) {
        if ([child isKindOfClass:%c(IGBadgedNavigationButton)]) {
            containsClass = YES;
            break;
        }
    }

    if (!containsClass) {
        return %orig;
    }

    NSMutableArray *newChildren = [children mutableCopy];

    // Add button to children array
    //UIBarButtonItem *bhSettingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"gear.circle"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySettingsModal)];
    // IGBadgedNavigationButton *badgedNavButton = [IGBadgedNavigationButton new];

    //UIButton *newButton = [UIButton buttonWithType:UIButtonTypeSystem];
    //[badgedNavButton ]

    //[newChildren addObject:badgedNavButton];

    // Make children array immutable
    //NSArray *immutableNewChildren = [newChildren copy]; 
    NSLog(@"[BHInsta] Old Children: %@", children); 
    NSLog(@"[BHInsta] New Children: %@", newChildren);
    

    return %orig(newChildren);
}
%end */