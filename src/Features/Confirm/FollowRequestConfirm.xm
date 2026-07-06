#import <substrate.h>
#import "../../Utils.h"

// NOTE: Logos' bare %orig substitution corrupts the surrounding braces when
// used inside a nested block literal (e.g. inside a showConfirmation
// completion handler), so these hooks are implemented manually via
// MSHookMessageEx with a captured C function pointer instead of %hook/%orig.

static void (*orig_onApproveButtonTapped)(id, SEL);
static void hooked_onApproveButtonTapped(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"follow_request_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow request triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_onApproveButtonTapped(self, _cmd);
        }];

        return;
    }

    orig_onApproveButtonTapped(self, _cmd);
}

static void (*orig_onIgnoreButtonTapped)(id, SEL);
static void hooked_onIgnoreButtonTapped(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"follow_request_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow request triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_onIgnoreButtonTapped(self, _cmd);
        }];

        return;
    }

    orig_onIgnoreButtonTapped(self, _cmd);
}

%ctor {
    Class cls = objc_getClass("IGPendingRequestView");
    if (!cls) return;

    MSHookMessageEx(cls, @selector(_onApproveButtonTapped), (IMP)hooked_onApproveButtonTapped, (IMP *)&orig_onApproveButtonTapped);
    MSHookMessageEx(cls, @selector(_onIgnoreButtonTapped), (IMP)hooked_onIgnoreButtonTapped, (IMP *)&orig_onIgnoreButtonTapped);
}
