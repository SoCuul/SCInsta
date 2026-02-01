#import "../../Utils.h"
#import "../../InstagramHeaders.h"

%hook IGStoryTextEntryControlsOverlayView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIUtils getBoolPref:@"enable_hidden_texteffectsstyles"]) {
    
        // Clear previous option values
        [self.animationTypes removeAllObjects];
        [self.effectTypes removeAllObjects];

        // Generate new option values
        for (int i = 0; i <= 100; i++) {
            [self.effectTypes addObject:@(i)];

            // Animation effects <= 9 are invalid
            if (i > 9) {
                [self.animationTypes addObject:@(i)];
            }
        }

        // Refresh option picker
        if ([self respondsToSelector:@selector(reloadData)]) {
            NSLog(@"[SCInsta] Enable all text effects: Reloading data...");
            [self reloadData];
        }

    }
}
%end