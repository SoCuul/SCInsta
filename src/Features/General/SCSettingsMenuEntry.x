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

    UIViewController *rootController = [[self window] rootViewController];
    SCISettingsViewController *settingsViewController = [SCISettingsViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    [rootController presentViewController:navigationController animated:YES completion:nil];
}
%end