#import "../../InstagramHeaders.h"
#import "../../Manager.h"

%hook IGTabBar
- (void)didMoveToWindow {
    %orig;

    NSMutableArray *_tabButtons = MSHookIvar<NSArray *>(self, "_tabButtons");
    if (_tabButtons == nil) return;

    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[_tabButtons count]];

    for (UIView *obj in _tabButtons) {
        BOOL shouldHide = NO;

        // Explore/search tab
        if ([SCIManager getPref:@"hide_explore_tab"] && [obj.accessibilityIdentifier isEqualToString:@"explore-tab"]) {
            NSLog(@"[SCInsta] Hiding explore/search tab");

            shouldHide = YES;

            [obj setHidden:YES];
        }

        // Create/camera tab
        else if ([SCIManager getPref:@"hide_create_tab"] && [obj.accessibilityIdentifier isEqualToString:@"camera-tab"]) {
            NSLog(@"[SCInsta] Hiding create/camera tab");

            shouldHide = YES;

            [obj setHidden:YES];
        }

        // Reels tab
        else if ([SCIManager getPref:@"hide_reels_tab"] && [obj.accessibilityIdentifier isEqualToString:@"reels-tab"]) {
            NSLog(@"[SCInsta] Hiding reels tab");

            shouldHide = YES;

            [obj setHidden:YES];
        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }
    }

    [_tabButtons setArray:filteredObjs];
}
%end