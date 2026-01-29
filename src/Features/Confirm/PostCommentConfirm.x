#import "../../Utils.h"

%hook IGCommentComposer.IGCommentComposerController
- (void)onSendButtonTap {
    if ([SCIUtils getBoolPref:@"post_comment_confirm"]) {
        NSLog(@"[SCInsta] Confirm post comment triggered");

        [SCIUtils showConfirmation:^(void) { %orig; }];
    } else {
        return %orig;
    }
}
%end