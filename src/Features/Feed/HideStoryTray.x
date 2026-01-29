#import "../../Utils.h"
#import "../../InstagramHeaders.h"

// Disable story data source
%hook IGMainStoryTrayDataSource
- (id)initWithUserSession:(id)arg1 {
    if ([SCIUtils getBoolPref:@"hide_stories_tray"]) {
        NSLog(@"[SCInsta] Hiding story tray");

        return nil;
    }
    
    return %orig;
}
%end