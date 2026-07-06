#import <substrate.h>
#import "../../InstagramHeaders.h"
#import "../../Utils.h"

// NOTE: Logos' bare %orig substitution corrupts the surrounding braces when
// used inside a nested block literal (e.g. inside a showConfirmation
// completion handler), so these hooks are implemented manually via
// MSHookMessageEx with a captured C function pointer instead of %hook/%orig.

static void (*orig_themeNewPickerSectionControllerDidSelectTheme)(id, SEL, id, id, NSInteger);
static void hooked_themeNewPickerSectionControllerDidSelectTheme(id self, SEL _cmd, id arg1, id arg2, NSInteger arg3) {
    if ([SCIUtils getBoolPref:@"change_direct_theme_confirm"]) {
        NSLog(@"[SCInsta] Confirm change direct theme triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_themeNewPickerSectionControllerDidSelectTheme(self, _cmd, arg1, arg2, arg3);
        }];

        return;
    }

    orig_themeNewPickerSectionControllerDidSelectTheme(self, _cmd, arg1, arg2, arg3);
}

static void (*orig_themePickerSectionControllerDidSelectThemeId)(id, SEL, id, id);
static void hooked_themePickerSectionControllerDidSelectThemeId(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"change_direct_theme_confirm"]) {
        NSLog(@"[SCInsta] Confirm change direct theme triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_themePickerSectionControllerDidSelectThemeId(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_themePickerSectionControllerDidSelectThemeId(self, _cmd, arg1, arg2);
}

static void (*orig_primaryButtonTapped)(id, SEL);
static void hooked_primaryButtonTapped(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"change_direct_theme_confirm"]) {
        NSLog(@"[SCInsta] Confirm change direct theme triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_primaryButtonTapped(self, _cmd);
        }];

        return;
    }

    orig_primaryButtonTapped(self, _cmd);
}

%ctor {
    Class cls;

    cls = objc_getClass("IGDirectThreadThemePickerViewController");
    if (cls) {
        MSHookMessageEx(cls, @selector(themeNewPickerSectionController:didSelectTheme:atIndex:), (IMP)hooked_themeNewPickerSectionControllerDidSelectTheme, (IMP *)&orig_themeNewPickerSectionControllerDidSelectTheme);
        MSHookMessageEx(cls, @selector(themePickerSectionController:didSelectThemeId:), (IMP)hooked_themePickerSectionControllerDidSelectThemeId, (IMP *)&orig_themePickerSectionControllerDidSelectThemeId);
    }

    cls = objc_getClass("IGDirectThreadThemeKitSwift.IGDirectThreadThemePreviewController");
    if (cls) {
        MSHookMessageEx(cls, @selector(primaryButtonTapped), (IMP)hooked_primaryButtonTapped, (IMP *)&orig_primaryButtonTapped);
    }
}
