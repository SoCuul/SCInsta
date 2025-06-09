#import "../../Manager.h"
#import "../../Utils.h"

///////////////////////////////////////////////////////////

// Confirmation handlers

#define CONFIRMPOSTLIKE(orig)                             \
    if ([SCIManager getPref:@"like_confirm"]) {           \
        NSLog(@"[SCInsta] Confirm post like triggered");  \
                                                          \
        [SCIUtils showConfirmation:^(void) { orig; }];    \
    }                                                     \
    else {                                                \
        return orig;                                      \
    }                                                     \

#define CONFIRMREELSLIKE(orig)                            \
    if ([SCIManager getPref:@"like_confirm_reels"]) {     \
        NSLog(@"[SCInsta] Confirm reels like triggered"); \
                                                          \
        [SCIUtils showConfirmation:^(void) { orig; }];    \
    }                                                     \
    else {                                                \
        return orig;                                      \
    }                                                     \

///////////////////////////////////////////////////////////

// Liking posts
%hook IGUFIButtonBarView
- (void)_onLikeButtonPressed:(id)arg1 {
    CONFIRMPOSTLIKE(%orig);
}
%end
%hook IGFeedPhotoView
- (void)_onDoubleTap:(id)arg1 {
    CONFIRMPOSTLIKE(%orig);
}
%end
%hook IGVideoPlayerOverlayContainerView
- (void)_handleDoubleTapGesture:(id)arg1 {
    CONFIRMPOSTLIKE(%orig);
}
%end
%hook IGFeedItemUFICell
- (void)UFIButtonBarDidTapOnLike:(id)arg1 {
    CONFIRMPOSTLIKE(%orig);
}
%end

// Liking reels
%hook IGSundialViewerVideoCell
- (void)controlsOverlayControllerDidTapLikeButton:(id)arg1 {
    CONFIRMREELSLIKE(%orig);
}
- (void)controlsOverlayControllerDidLongPressLikeButton:(id)arg1 gestureRecognizer:(id)arg2 {
    CONFIRMREELSLIKE(%orig);
}
- (void)gestureController:(id)arg1 didObserveDoubleTap:(id)arg2 {
    CONFIRMREELSLIKE(%orig);
}
%end
%hook IGSundialViewerPhotoCell
- (void)controlsOverlayControllerDidTapLikeButton:(id)arg1 {
    CONFIRMREELSLIKE(%orig);
}
- (void)gestureController:(id)arg1 didObserveDoubleTap:(id)arg2 {
    CONFIRMREELSLIKE(%orig);
}
%end
%hook IGSundialViewerCarouselCell
- (void)controlsOverlayControllerDidTapLikeButton:(id)arg1 {
    CONFIRMREELSLIKE(%orig);
}
- (void)gestureController:(id)arg1 didObserveDoubleTap:(id)arg2 {
    CONFIRMREELSLIKE(%orig);
}
%end

// Liking comments
%hook IGCommentCellController
- (void)commentCell:(id)arg1 didTapLikeButton:(id)arg2 {
    CONFIRMPOSTLIKE(%orig);
}
- (void)commentCell:(id)arg1 didTapLikedByButtonForUser:(id)arg2 {
    CONFIRMPOSTLIKE(%orig);
}
- (void)commentCellDidLongPressOnLikeButton:(id)arg1 {
    CONFIRMPOSTLIKE(%orig);
}
- (void)commentCellDidEndLongPressOnLikeButton:(id)arg1 {
    CONFIRMPOSTLIKE(%orig);
}
- (void)commentCellDidDoubleTap:(id)arg1 {
    CONFIRMPOSTLIKE(%orig);
}
%end
%hook IGFeedItemPreviewCommentCell
- (void)_didTapLikeButton {
    CONFIRMPOSTLIKE(%orig);
}
%end

// Liking stories
%hook IGStoryFullscreenDefaultFooterView
- (void)_handleLikeTapped {
    CONFIRMPOSTLIKE(%orig);
}
- (void)_likeTapped {
    CONFIRMPOSTLIKE(%orig);
}
- (void)inputView:(id)arg1 didTapLikeButton:(id)arg2 {
    CONFIRMPOSTLIKE(%orig);
}
%end

// DM like button (seems to be hidden)
%hook IGDirectThreadViewController
- (void)_didTapLikeButton {
    CONFIRMPOSTLIKE(%orig);
}
%end