#import <substrate.h>
#import "../../Utils.h"

// NOTE: Logos' bare %orig substitution corrupts the surrounding braces when
// used inside a nested block literal (e.g. inside a showConfirmation
// completion handler), so this hook is implemented manually via
// MSHookMessageEx with a captured C function pointer instead of %hook/%orig.

static void (*orig_onSendButtonTap)(id, SEL);
static void hooked_onSendButtonTap(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"post_comment_confirm"]) {
        NSLog(@"[SCInsta] Confirm post comment triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_onSendButtonTap(self, _cmd);
        }];

        return;
    }

    orig_onSendButtonTap(self, _cmd);
}

%ctor {
    Class cls = objc_getClass("IGCommentComposer.IGCommentComposerController");
    if (!cls) return;

    MSHookMessageEx(cls, @selector(onSendButtonTap), (IMP)hooked_onSendButtonTap, (IMP *)&orig_onSendButtonTap);
}
