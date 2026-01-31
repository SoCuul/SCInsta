#import "../../Utils.h"

%hook IGSundialViewerNavigationBarOld
- (void)didMoveToWindow {
    %orig;

    if ([SCIUtils getBoolPref:@"hide_reels_header"]) {
        NSLog(@"[SCInsta] Hiding reels header");

        [self removeFromSuperview];
    }
}
%end
