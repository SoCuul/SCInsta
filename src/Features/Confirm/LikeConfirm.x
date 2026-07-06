#import <substrate.h>
#import "../../Utils.h"

///////////////////////////////////////////////////////////
// NOTE: Logos' bare %orig substitution corrupts the surrounding braces when
// used inside a nested block literal (e.g. inside a showConfirmation
// completion handler). Every hook here that needs to defer the original
// call until the user confirms is therefore implemented manually via
// MSHookMessageEx with a captured C function pointer instead of %hook/%orig.
///////////////////////////////////////////////////////////

// Liking posts
static void (*orig_onLikeButtonPressed)(id, SEL, id);
static void hooked_onLikeButtonPressed(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_onLikeButtonPressed(self, _cmd, arg1);
        }];

        return;
    }

    orig_onLikeButtonPressed(self, _cmd, arg1);
}

static void (*orig_onDoubleTap)(id, SEL, id);
static void hooked_onDoubleTap(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_onDoubleTap(self, _cmd, arg1);
        }];

        return;
    }

    orig_onDoubleTap(self, _cmd, arg1);
}

static void (*orig_handleDoubleTapGesture)(id, SEL, id);
static void hooked_handleDoubleTapGesture(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_handleDoubleTapGesture(self, _cmd, arg1);
        }];

        return;
    }

    orig_handleDoubleTapGesture(self, _cmd, arg1);
}

// Liking reels
static void (*orig_videoCellControlsOverlayControllerDidTapLikeButton)(id, SEL, id);
static void hooked_videoCellControlsOverlayControllerDidTapLikeButton(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"like_confirm_reels"]) {
        NSLog(@"[SCInsta] Confirm reels like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_videoCellControlsOverlayControllerDidTapLikeButton(self, _cmd, arg1);
        }];

        return;
    }

    orig_videoCellControlsOverlayControllerDidTapLikeButton(self, _cmd, arg1);
}

static void (*orig_videoCellControlsOverlayControllerDidLongPressLikeButton)(id, SEL, id, id);
static void hooked_videoCellControlsOverlayControllerDidLongPressLikeButton(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"like_confirm_reels"]) {
        NSLog(@"[SCInsta] Confirm reels like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_videoCellControlsOverlayControllerDidLongPressLikeButton(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_videoCellControlsOverlayControllerDidLongPressLikeButton(self, _cmd, arg1, arg2);
}

static void (*orig_videoCellGestureControllerDidObserveDoubleTap)(id, SEL, id, id);
static void hooked_videoCellGestureControllerDidObserveDoubleTap(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"like_confirm_reels"]) {
        NSLog(@"[SCInsta] Confirm reels like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_videoCellGestureControllerDidObserveDoubleTap(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_videoCellGestureControllerDidObserveDoubleTap(self, _cmd, arg1, arg2);
}

static void (*orig_photoCellControlsOverlayControllerDidTapLikeButton)(id, SEL, id);
static void hooked_photoCellControlsOverlayControllerDidTapLikeButton(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"like_confirm_reels"]) {
        NSLog(@"[SCInsta] Confirm reels like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_photoCellControlsOverlayControllerDidTapLikeButton(self, _cmd, arg1);
        }];

        return;
    }

    orig_photoCellControlsOverlayControllerDidTapLikeButton(self, _cmd, arg1);
}

static void (*orig_photoCellGestureControllerDidObserveDoubleTap)(id, SEL, id, id);
static void hooked_photoCellGestureControllerDidObserveDoubleTap(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"like_confirm_reels"]) {
        NSLog(@"[SCInsta] Confirm reels like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_photoCellGestureControllerDidObserveDoubleTap(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_photoCellGestureControllerDidObserveDoubleTap(self, _cmd, arg1, arg2);
}

static void (*orig_carouselCellControlsOverlayControllerDidTapLikeButton)(id, SEL, id);
static void hooked_carouselCellControlsOverlayControllerDidTapLikeButton(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"like_confirm_reels"]) {
        NSLog(@"[SCInsta] Confirm reels like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_carouselCellControlsOverlayControllerDidTapLikeButton(self, _cmd, arg1);
        }];

        return;
    }

    orig_carouselCellControlsOverlayControllerDidTapLikeButton(self, _cmd, arg1);
}

static void (*orig_carouselCellGestureControllerDidObserveDoubleTap)(id, SEL, id, id);
static void hooked_carouselCellGestureControllerDidObserveDoubleTap(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"like_confirm_reels"]) {
        NSLog(@"[SCInsta] Confirm reels like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_carouselCellGestureControllerDidObserveDoubleTap(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_carouselCellGestureControllerDidObserveDoubleTap(self, _cmd, arg1, arg2);
}

// Liking comments
static void (*orig_commentCellDidTapLikeButton)(id, SEL, id, id);
static void hooked_commentCellDidTapLikeButton(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_commentCellDidTapLikeButton(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_commentCellDidTapLikeButton(self, _cmd, arg1, arg2);
}

static void (*orig_commentCellDidTapLikedByButtonForUser)(id, SEL, id, id);
static void hooked_commentCellDidTapLikedByButtonForUser(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_commentCellDidTapLikedByButtonForUser(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_commentCellDidTapLikedByButtonForUser(self, _cmd, arg1, arg2);
}

static void (*orig_commentCellDidLongPressOnLikeButton)(id, SEL, id);
static void hooked_commentCellDidLongPressOnLikeButton(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_commentCellDidLongPressOnLikeButton(self, _cmd, arg1);
        }];

        return;
    }

    orig_commentCellDidLongPressOnLikeButton(self, _cmd, arg1);
}

static void (*orig_commentCellDidEndLongPressOnLikeButton)(id, SEL, id);
static void hooked_commentCellDidEndLongPressOnLikeButton(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_commentCellDidEndLongPressOnLikeButton(self, _cmd, arg1);
        }];

        return;
    }

    orig_commentCellDidEndLongPressOnLikeButton(self, _cmd, arg1);
}

static void (*orig_commentCellDidDoubleTap)(id, SEL, id);
static void hooked_commentCellDidDoubleTap(id self, SEL _cmd, id arg1) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_commentCellDidDoubleTap(self, _cmd, arg1);
        }];

        return;
    }

    orig_commentCellDidDoubleTap(self, _cmd, arg1);
}

static void (*orig_previewCommentCellDidTapLikeButton)(id, SEL);
static void hooked_previewCommentCellDidTapLikeButton(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_previewCommentCellDidTapLikeButton(self, _cmd);
        }];

        return;
    }

    orig_previewCommentCellDidTapLikeButton(self, _cmd);
}

// Liking stories
static void (*orig_handleLikeTapped)(id, SEL);
static void hooked_handleLikeTapped(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_handleLikeTapped(self, _cmd);
        }];

        return;
    }

    orig_handleLikeTapped(self, _cmd);
}

static void (*orig_likeTapped)(id, SEL);
static void hooked_likeTapped(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_likeTapped(self, _cmd);
        }];

        return;
    }

    orig_likeTapped(self, _cmd);
}

static void (*orig_inputViewDidTapLikeButton)(id, SEL, id, id);
static void hooked_inputViewDidTapLikeButton(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_inputViewDidTapLikeButton(self, _cmd, arg1, arg2);
        }];

        return;
    }

    orig_inputViewDidTapLikeButton(self, _cmd, arg1, arg2);
}

// For some stupid reason they removed the "liketapped" methods on newer Instagram versions
// Now we have to do a shitty workaround instead :(
// Works 99% of the time, but sometimes clicks get through directly to the like button (somehow)
%hook IGStoryFullscreenDefaultFooterView
- (void)layoutSubviews {
    %orig;

    if (![SCIUtils getBoolPref:@"like_confirm"]) return;

    UIButton *likeButton = [self valueForKey:@"likeButton"];
    if (!likeButton) return;

    // 129115 = L(12) I(9) K(11) E(5)
    static NSInteger kOverlayTag = 129115;
    if ([likeButton viewWithTag:kOverlayTag]) return;

    UIButton *overlay = [UIButton buttonWithType:UIButtonTypeCustom];
    overlay.tag = kOverlayTag;
    overlay.frame = likeButton.bounds;
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [overlay addTarget:self action:@selector(overlayTapped:) forControlEvents:UIControlEventTouchUpInside];
    [likeButton addSubview:overlay];
}

%new - (void)overlayTapped:(UIButton *)overlay {
    UIButton *likeButton = (UIButton *)overlay.superview;

    [SCIUtils showConfirmation:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [likeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
    }];
}
%end

// DM like button (seems to be hidden)
static void (*orig_directThreadDidTapLikeButton)(id, SEL);
static void hooked_directThreadDidTapLikeButton(id self, SEL _cmd) {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_directThreadDidTapLikeButton(self, _cmd);
        }];

        return;
    }

    orig_directThreadDidTapLikeButton(self, _cmd);
}

%ctor {
    Class cls;

    cls = objc_getClass("IGUFIButtonBarView");
    if (cls) {
        MSHookMessageEx(cls, @selector(_onLikeButtonPressed:), (IMP)hooked_onLikeButtonPressed, (IMP *)&orig_onLikeButtonPressed);
    }

    cls = objc_getClass("IGFeedPhotoView");
    if (cls) {
        MSHookMessageEx(cls, @selector(_onDoubleTap:), (IMP)hooked_onDoubleTap, (IMP *)&orig_onDoubleTap);
    }

    cls = objc_getClass("IGVideoPlayerOverlayContainerView");
    if (cls) {
        MSHookMessageEx(cls, @selector(_handleDoubleTapGesture:), (IMP)hooked_handleDoubleTapGesture, (IMP *)&orig_handleDoubleTapGesture);
    }

    cls = objc_getClass("IGSundialViewerVideoCell");
    if (cls) {
        MSHookMessageEx(cls, @selector(controlsOverlayControllerDidTapLikeButton:), (IMP)hooked_videoCellControlsOverlayControllerDidTapLikeButton, (IMP *)&orig_videoCellControlsOverlayControllerDidTapLikeButton);
        MSHookMessageEx(cls, @selector(controlsOverlayControllerDidLongPressLikeButton:gestureRecognizer:), (IMP)hooked_videoCellControlsOverlayControllerDidLongPressLikeButton, (IMP *)&orig_videoCellControlsOverlayControllerDidLongPressLikeButton);
        MSHookMessageEx(cls, @selector(gestureController:didObserveDoubleTap:), (IMP)hooked_videoCellGestureControllerDidObserveDoubleTap, (IMP *)&orig_videoCellGestureControllerDidObserveDoubleTap);
    }

    cls = objc_getClass("IGSundialViewerPhotoCell");
    if (cls) {
        MSHookMessageEx(cls, @selector(controlsOverlayControllerDidTapLikeButton:), (IMP)hooked_photoCellControlsOverlayControllerDidTapLikeButton, (IMP *)&orig_photoCellControlsOverlayControllerDidTapLikeButton);
        MSHookMessageEx(cls, @selector(gestureController:didObserveDoubleTap:), (IMP)hooked_photoCellGestureControllerDidObserveDoubleTap, (IMP *)&orig_photoCellGestureControllerDidObserveDoubleTap);
    }

    cls = objc_getClass("IGSundialViewerCarouselCell");
    if (cls) {
        MSHookMessageEx(cls, @selector(controlsOverlayControllerDidTapLikeButton:), (IMP)hooked_carouselCellControlsOverlayControllerDidTapLikeButton, (IMP *)&orig_carouselCellControlsOverlayControllerDidTapLikeButton);
        MSHookMessageEx(cls, @selector(gestureController:didObserveDoubleTap:), (IMP)hooked_carouselCellGestureControllerDidObserveDoubleTap, (IMP *)&orig_carouselCellGestureControllerDidObserveDoubleTap);
    }

    cls = objc_getClass("IGCommentCellController");
    if (cls) {
        MSHookMessageEx(cls, @selector(commentCell:didTapLikeButton:), (IMP)hooked_commentCellDidTapLikeButton, (IMP *)&orig_commentCellDidTapLikeButton);
        MSHookMessageEx(cls, @selector(commentCell:didTapLikedByButtonForUser:), (IMP)hooked_commentCellDidTapLikedByButtonForUser, (IMP *)&orig_commentCellDidTapLikedByButtonForUser);
        MSHookMessageEx(cls, @selector(commentCellDidLongPressOnLikeButton:), (IMP)hooked_commentCellDidLongPressOnLikeButton, (IMP *)&orig_commentCellDidLongPressOnLikeButton);
        MSHookMessageEx(cls, @selector(commentCellDidEndLongPressOnLikeButton:), (IMP)hooked_commentCellDidEndLongPressOnLikeButton, (IMP *)&orig_commentCellDidEndLongPressOnLikeButton);
        MSHookMessageEx(cls, @selector(commentCellDidDoubleTap:), (IMP)hooked_commentCellDidDoubleTap, (IMP *)&orig_commentCellDidDoubleTap);
    }

    cls = objc_getClass("IGFeedItemPreviewCommentCell");
    if (cls) {
        MSHookMessageEx(cls, @selector(_didTapLikeButton), (IMP)hooked_previewCommentCellDidTapLikeButton, (IMP *)&orig_previewCommentCellDidTapLikeButton);
    }

    cls = objc_getClass("IGStoryFullscreenDefaultFooterView");
    if (cls) {
        MSHookMessageEx(cls, @selector(_handleLikeTapped), (IMP)hooked_handleLikeTapped, (IMP *)&orig_handleLikeTapped);
        MSHookMessageEx(cls, @selector(_likeTapped), (IMP)hooked_likeTapped, (IMP *)&orig_likeTapped);
        MSHookMessageEx(cls, @selector(inputView:didTapLikeButton:), (IMP)hooked_inputViewDidTapLikeButton, (IMP *)&orig_inputViewDidTapLikeButton);
    }

    cls = objc_getClass("IGDirectThreadViewController");
    if (cls) {
        MSHookMessageEx(cls, @selector(_didTapLikeButton), (IMP)hooked_directThreadDidTapLikeButton, (IMP *)&orig_directThreadDidTapLikeButton);
    }
}
