#import <substrate.h>
#import "../../Utils.h"
#import "../../InstagramHeaders.h"

////////////////////////////////////////////////////////
// NOTE: Logos' bare %orig substitution corrupts the surrounding braces when
// used inside a nested block literal (e.g. inside a showConfirmation
// completion handler). Every hook here that needs to defer the original
// call until the user confirms is therefore implemented manually via
// MSHookMessageEx with a captured C function pointer instead of %hook/%orig.
////////////////////////////////////////////////////////

// Follow button on profile page
static void (*orig_didPressFollowButton)(id, SEL);
static void hooked_didPressFollowButton(id self, SEL _cmd) {
    NSInteger UserFollowStatus = ((IGFollowController *)self).user.followStatus;

    // Only show confirm dialog if user is not following
    if (UserFollowStatus == 2 && [SCIUtils getBoolPref:@"follow_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_didPressFollowButton(self, _cmd);
        }];

        return;
    }

    orig_didPressFollowButton(self, _cmd);
}

// Follow button on discover people page
static void (*orig_onFollowButtonTapped)(id, SEL, id);
static void hooked_onFollowButtonTapped(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"follow_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_onFollowButtonTapped(self, _cmd, arg1);
        }];

        return;
    }

    orig_onFollowButtonTapped(self, _cmd, arg1);
}

static void (*orig_onFollowingButtonTapped)(id, SEL, id);
static void hooked_onFollowingButtonTapped(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"follow_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_onFollowingButtonTapped(self, _cmd, arg1);
        }];

        return;
    }

    orig_onFollowingButtonTapped(self, _cmd, arg1);
}

// Suggested for you (home feed & profile) follow button
static void (*orig_didTapAYMFActionButton)(id, SEL);
static void hooked_didTapAYMFActionButton(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"follow_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_didTapAYMFActionButton(self, _cmd);
        }];

        return;
    }

    orig_didTapAYMFActionButton(self, _cmd);
}

static void (*orig_didTapTextActionButton)(id, SEL);
static void hooked_didTapTextActionButton(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"follow_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_didTapTextActionButton(self, _cmd);
        }];

        return;
    }

    orig_didTapTextActionButton(self, _cmd);
}

// Follow button on reels
static void (*orig_hackilyHandleOurOwnButtonTaps)(id, SEL, id, id);
static void hooked_hackilyHandleOurOwnButtonTaps(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"follow_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_hackilyHandleOurOwnButtonTaps(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_hackilyHandleOurOwnButtonTaps(self, _cmd, arg1, arg2);
}

// Follow text on profile (when collapsed into top bar)
static void (*orig_navigationItemsControllerDidTapHeaderFollowButton)(id, SEL, id);
static void hooked_navigationItemsControllerDidTapHeaderFollowButton(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"follow_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_navigationItemsControllerDidTapHeaderFollowButton(self, _cmd, arg1);
        }];

        return;
    }

    orig_navigationItemsControllerDidTapHeaderFollowButton(self, _cmd, arg1);
}

// Follow button on suggested friends (in story section)
static void (*orig_followButtonTappedCell)(id, SEL, id, id);
static void hooked_followButtonTappedCell(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"follow_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_followButtonTappedCell(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_followButtonTappedCell(self, _cmd, arg1, arg2);
}

// Follow all button in group chats (3+ members) people view
static void (*orig_listSectionController)(id, SEL, id, id);
static void hooked_listSectionController(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"follow_confirm"]) {

        [SCIUtils showConfirmation:^{
            orig_listSectionController(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_listSectionController(self, _cmd, arg1, arg2);
}

%ctor {
    Class cls;

    cls = objc_getClass("IGFollowController");
    if (cls) {
        MSHookMessageEx(
            cls,
            @selector(_didPressFollowButton),
            (IMP)hooked_didPressFollowButton,
            (IMP *)&orig_didPressFollowButton
        );
    }

    cls = objc_getClass("IGDiscoverPeopleButtonGroupView");
    if (cls) {
        MSHookMessageEx(
            cls,
            @selector(_onFollowButtonTapped:),
            (IMP)hooked_onFollowButtonTapped,
            (IMP *)&orig_onFollowButtonTapped
        );
        MSHookMessageEx(
            cls,
            @selector(_onFollowingButtonTapped:),
            (IMP)hooked_onFollowingButtonTapped,
            (IMP *)&orig_onFollowingButtonTapped
        );
    }

    cls = objc_getClass("IGHScrollAYMFCell");
    if (cls) {
        MSHookMessageEx(
            cls,
            @selector(_didTapAYMFActionButton),
            (IMP)hooked_didTapAYMFActionButton,
            (IMP *)&orig_didTapAYMFActionButton
        );
    }

    cls = objc_getClass("IGHScrollAYMFActionButton");
    if (cls) {
        MSHookMessageEx(
            cls,
            @selector(_didTapTextActionButton),
            (IMP)hooked_didTapTextActionButton,
            (IMP *)&orig_didTapTextActionButton
        );
    }

    cls = objc_getClass("IGUnifiedVideoFollowButton");
    if (cls) {
        MSHookMessageEx(
            cls,
            @selector(_hackilyHandleOurOwnButtonTaps:event:),
            (IMP)hooked_hackilyHandleOurOwnButtonTaps,
            (IMP *)&orig_hackilyHandleOurOwnButtonTaps
        );
    }

    cls = objc_getClass("IGProfileViewController");
    if (cls) {
        MSHookMessageEx(
            cls,
            @selector(navigationItemsControllerDidTapHeaderFollowButton:),
            (IMP)hooked_navigationItemsControllerDidTapHeaderFollowButton,
            (IMP *)&orig_navigationItemsControllerDidTapHeaderFollowButton
        );
    }

    cls = objc_getClass("IGStorySectionController");
    if (cls) {
        MSHookMessageEx(
            cls,
            @selector(followButtonTapped:cell:),
            (IMP)hooked_followButtonTappedCell,
            (IMP *)&orig_followButtonTappedCell
        );
    }

    cls = objc_getClass("IGDirectDetailMembersKit.IGDirectThreadDetailsMembersListViewController");
    if (cls) {
        MSHookMessageEx(
            cls,
            @selector(listSectionController:didTapHeaderButtonWithViewModel:),
            (IMP)hooked_listSectionController,
            (IMP *)&orig_listSectionController
        );
    }
}
