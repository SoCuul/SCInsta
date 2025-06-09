#import "../../InstagramHeaders.h"
#import "../../Manager.h"

%hook IGExploreGridViewController
- (void)viewDidLoad {
    if ([SCIManager getPref:@"hide_explore_grid"]) {
        NSLog(@"[SCInsta] Hiding explore grid");

        [[self view] removeFromSuperview];

        return;
    }
    
    return %orig;
}
%end

%hook IGExploreViewController
- (void)viewDidLoad {
    %orig;

    if ([SCIManager getPref:@"hide_explore_grid"]) {
        NSLog(@"[SCInsta] Hiding explore grid");

        IGShimmeringGridView *shimmeringGridView = MSHookIvar<IGShimmeringGridView *>(self, "_shimmeringGridView");
        if (shimmeringGridView != nil) {
            [shimmeringGridView removeFromSuperview];
        }
    }
}
%end