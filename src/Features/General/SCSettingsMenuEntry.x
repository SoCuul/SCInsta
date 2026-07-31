#import "../../InstagramHeaders.h"
#import "../../Settings/SCISettingsViewController.h"
#import <objc/runtime.h>

static char SCInstaSettingsLongPressGestureRecognizerKey;

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
    UILongPressGestureRecognizer *longPress = objc_getAssociatedObject(self, &SCInstaSettingsLongPressGestureRecognizerKey);

    if (longPress == nil) {
        NSLog(@"[SCInsta] Adding tweak settings long press gesture recognizer");

        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        objc_setAssociatedObject(self, &SCInstaSettingsLongPressGestureRecognizerKey, longPress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    if (longPress.view != self) {
        [self addGestureRecognizer:longPress];
    }

    for (UIGestureRecognizer *existing in self.gestureRecognizers) {
        if (existing != longPress) {
            [existing requireGestureRecognizerToFail:longPress];
        }
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