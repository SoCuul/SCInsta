#import "../../InstagramHeaders.h"
#import "../../Settings/SCISettingsViewController.h"

// Show SCInsta tweak settings by holding on the settings/more icon under profile for ~1 second
%hook IGBadgedNavigationButton
- (void)didMoveToWindow {
    %orig;

    if ([self.accessibilityIdentifier isEqualToString:@"profile-more-button"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}

%new - (void)addLongPressGestureRecognizer {
    if ([self.gestureRecognizers count] == 0) {
        NSLog(@"[SCInsta] Adding tweak settings long press gesture recognizer");

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPress];
    }
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;
    
    NSLog(@"[SCInsta] Tweak settings gesture activated");

    [SCIUtils showSettingsVC:[self window]];
}
%end

// Quick access to tweak settings by holding on home tab button
%hook IGTabBarButton
- (void)didMoveToSuperview {
    %orig;

    // Only work on home/feed tab
    if (![self.accessibilityIdentifier isEqualToString:@"mainfeed-tab"]) return;
    
    if ([SCIUtils getBoolPref:@"settings_shortcut"]) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPress.minimumPressDuration = 0.3;
        
        // Take precidence over existing gesture recognizers
        for (UIGestureRecognizer *existing in self.gestureRecognizers) {
            [existing requireGestureRecognizerToFail:longPress];
        }
        
        [self addGestureRecognizer:longPress];
    }
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    [SCIUtils showSettingsVC:[self window]];
}
%end

// Tapping the side tray (hamburger) button on the profile lets the user choose
// between the normal Instagram settings and the SCInsta tweak settings
@protocol SCSideTrayController
- (void)onSideTrayButton;
@end

static BOOL sciBypassSideTray = NO;

%hook _TtC19IGProfileNavigation34IGProfileNavigationItemsController
- (void)onSideTrayButton {
    // Re-entrant call from the "Instagram Settings" option: run the original
    if (sciBypassSideTray) {
        sciBypassSideTray = NO;
        %orig;
        return;
    }

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *presenter = [window rootViewController];
    while (presenter.presentedViewController) presenter = presenter.presentedViewController;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Settings"
                                                                  message:@"Which settings would you like to open?"
                                                           preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"Instagram Settings"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        sciBypassSideTray = YES;
        [(id<SCSideTrayController>)self onSideTrayButton];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"SCInsta Settings"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        [SCIUtils showSettingsVC:window];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    // Required for iPad to avoid a crash when presenting an action sheet
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.sourceView = presenter.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(presenter.view.bounds.size.width / 2.0, presenter.view.bounds.size.height / 2.0, 1.0, 1.0);
    }

    [presenter presentViewController:alert animated:YES completion:nil];
}
%end