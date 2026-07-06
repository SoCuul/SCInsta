#import <substrate.h>
#import "../../Utils.h"

// NOTE: Logos' bare %orig substitution corrupts the surrounding braces when
// used inside a nested block literal (e.g. inside a showConfirmation
// completion handler), so hooks that defer to a confirmation dialog are
// implemented manually via MSHookMessageEx with a captured C function
// pointer instead of %hook/%orig.

// Legacy hook (for non ai voices interface)
static void (*orig_voiceRecordViewControllerDidRecordAudioClip)(id, SEL, id, id, id, CGFloat, NSInteger);
static void hooked_voiceRecordViewControllerDidRecordAudioClip(id self, SEL _cmd, id arg1, id arg2, id arg3, CGFloat arg4, NSInteger arg5) {
    if ([SCIUtils getBoolPref:@"voice_message_confirm"]) {
        NSLog(@"[SCInsta] DM audio message confirm triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_voiceRecordViewControllerDidRecordAudioClip(self, _cmd, arg1, arg2, arg3, arg4, arg5);
        }];

        return;
    }

    orig_voiceRecordViewControllerDidRecordAudioClip(self, _cmd, arg1, arg2, arg3, arg4, arg5);
}

// Workaround until I can figure out how to stop long press recording from automatically sending
%hook IGDirectComposer
- (void)_didLongPressVoiceMessage:(id)arg1 {
    if ([SCIUtils getBoolPref:@"voice_message_confirm"]) {
        return;
    } else {
        return %orig;
    }
}
%end

// Demangled name: IGDirectAIVoiceUIKit.CompactBarContentView
static void (*orig_didTapSend)(id, SEL);
static void hooked_didTapSend(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"voice_message_confirm"]) {
        NSLog(@"[SCInsta] DM audio message confirm triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_didTapSend(self, _cmd);
        }];

        return;
    }

    orig_didTapSend(self, _cmd);
}

%ctor {
    Class cls;

    cls = objc_getClass("IGDirectThreadViewController");
    if (cls) {
        MSHookMessageEx(cls, @selector(voiceRecordViewController:didRecordAudioClipWithURL:waveform:duration:entryPoint:), (IMP)hooked_voiceRecordViewControllerDidRecordAudioClip, (IMP *)&orig_voiceRecordViewControllerDidRecordAudioClip);
    }

    cls = objc_getClass("_TtC20IGDirectAIVoiceUIKitP33_5754F7617E0D924F9A84EFA352BBD29A21CompactBarContentView");
    if (cls) {
        MSHookMessageEx(cls, @selector(didTapSend), (IMP)hooked_didTapSend, (IMP *)&orig_didTapSend);
    }
}
