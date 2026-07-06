#import <substrate.h>
#import "../../Utils.h"

// NOTE: Logos' bare %orig substitution corrupts the surrounding braces when
// used inside a nested block literal (e.g. inside a showConfirmation
// completion handler), so these hooks are implemented manually via
// MSHookMessageEx with a captured C function pointer instead of %hook/%orig.

// Voice Call
static void (*orig_didTapAudioButton)(id, SEL, id);
static void hooked_didTapAudioButton(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"call_confirm"]) {
        NSLog(@"[SCInsta] Call confirm triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_didTapAudioButton(self, _cmd, arg1);
        }];

        return;
    }

    orig_didTapAudioButton(self, _cmd, arg1);
}

// Video Call
static void (*orig_didTapVideoButton)(id, SEL, id);
static void hooked_didTapVideoButton(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"call_confirm"]) {
        NSLog(@"[SCInsta] Call confirm triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_didTapVideoButton(self, _cmd, arg1);
        }];

        return;
    }

    orig_didTapVideoButton(self, _cmd, arg1);
}

%ctor {
    Class cls = objc_getClass("IGDirectThreadCallButtonsCoordinator");
    if (!cls) return;

    MSHookMessageEx(cls, @selector(_didTapAudioButton:), (IMP)hooked_didTapAudioButton, (IMP *)&orig_didTapAudioButton);
    MSHookMessageEx(cls, @selector(_didTapVideoButton:), (IMP)hooked_didTapVideoButton, (IMP *)&orig_didTapVideoButton);
}
