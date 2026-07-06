#import <substrate.h>
#import "../../Utils.h"

// NOTE: Logos' bare %orig substitution corrupts the surrounding braces when
// used inside a nested block literal (e.g. inside a showConfirmation
// completion handler), so these hooks are implemented manually via
// MSHookMessageEx with a captured C function pointer instead of %hook/%orig.

static void (*orig_swipeableScrollManagerDidEndDraggingAboveSwipeThreshold)(id, SEL, id);
static void hooked_swipeableScrollManagerDidEndDraggingAboveSwipeThreshold(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"shh_mode_confirm"]) {
        NSLog(@"[SCInsta] Confirm shh mode triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_swipeableScrollManagerDidEndDraggingAboveSwipeThreshold(self, _cmd, arg1);
        }];

        return;
    }

    orig_swipeableScrollManagerDidEndDraggingAboveSwipeThreshold(self, _cmd, arg1);
}

static void (*orig_shhModeTransitionButtonDidTap)(id, SEL, id);
static void hooked_shhModeTransitionButtonDidTap(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"shh_mode_confirm"]) {
        NSLog(@"[SCInsta] Confirm shh mode triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_shhModeTransitionButtonDidTap(self, _cmd, arg1);
        }];

        return;
    }

    orig_shhModeTransitionButtonDidTap(self, _cmd, arg1);
}

static void (*orig_messageListViewControllerDidToggleShhMode)(id, SEL, id);
static void hooked_messageListViewControllerDidToggleShhMode(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"shh_mode_confirm"]) {
        NSLog(@"[SCInsta] Confirm shh mode triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_messageListViewControllerDidToggleShhMode(self, _cmd, arg1);
        }];

        return;
    }

    orig_messageListViewControllerDidToggleShhMode(self, _cmd, arg1);
}

%ctor {
    Class cls = objc_getClass("IGDirectThreadViewController");
    if (!cls) return;

    MSHookMessageEx(cls, @selector(swipeableScrollManagerDidEndDraggingAboveSwipeThreshold:), (IMP)hooked_swipeableScrollManagerDidEndDraggingAboveSwipeThreshold, (IMP *)&orig_swipeableScrollManagerDidEndDraggingAboveSwipeThreshold);
    MSHookMessageEx(cls, @selector(shhModeTransitionButtonDidTap:), (IMP)hooked_shhModeTransitionButtonDidTap, (IMP *)&orig_shhModeTransitionButtonDidTap);
    MSHookMessageEx(cls, @selector(messageListViewControllerDidToggleShhMode:), (IMP)hooked_messageListViewControllerDidToggleShhMode, (IMP *)&orig_messageListViewControllerDidToggleShhMode);
}
