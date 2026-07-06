#import <substrate.h>
#import "../../Utils.h"

// NOTE: Logos' bare %orig substitution corrupts the surrounding braces when
// used inside a nested block literal (e.g. inside a showConfirmation
// completion handler), so this hook is implemented manually via
// MSHookMessageEx with a captured C function pointer instead of %hook/%orig.

static void (*orig_didTapForEvent)(id, SEL, id, id);
static void hooked_didTapForEvent(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"sticker_interact_confirm"]) {
        NSLog(@"[SCInsta] Confirm sticker interact triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_didTapForEvent(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_didTapForEvent(self, _cmd, arg1, arg2);
}

%ctor {
    Class cls = objc_getClass("IGStoryViewerTapTarget");
    if (!cls) return;

    MSHookMessageEx(cls, @selector(_didTap:forEvent:), (IMP)hooked_didTapForEvent, (IMP *)&orig_didTapForEvent);
}
