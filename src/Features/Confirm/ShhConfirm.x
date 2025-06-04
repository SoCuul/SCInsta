#import "../../Manager.h"
#import "../../Utils.h"

%hook IGDirectThreadViewController
- (void)swipeableScrollManagerDidEndDraggingAboveSwipeThreshold:(id)arg1 {
    if ([SCIManager getPref:@"shh_mode_confirm"]) {
        NSLog(@"[SCInsta] Confirm shh mode triggered");

        [SCIUtils showConfirmation:^(void) { %orig; }];
    } else {
        return %orig;
    }
}

- (void)shhModeTransitionButtonDidTap:(id)arg1 {
    if ([SCIManager getPref:@"shh_mode_confirm"]) {
        NSLog(@"[SCInsta] Confirm shh mode triggered");

        [SCIUtils showConfirmation:^(void) { %orig; }];
    } else {
        return %orig;
    }
}

- (void)messageListViewControllerDidToggleShhMode:(id)arg1 {
    if ([SCIManager getPref:@"shh_mode_confirm"]) {
        NSLog(@"[SCInsta] Confirm shh mode triggered");

        [SCIUtils showConfirmation:^(void) { %orig; }];
    } else {
        return %orig;
    }
}
%end