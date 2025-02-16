#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Hide reels tab and create tab
%hook IGTabBarController

- (id)initWithUserSession:(id)a tabBarSurfaces:(id)b accountSwitcherPresenter:(id)c initMode:(NSInteger)d {
    
    NSMutableArray *surfaces = [NSMutableArray arrayWithArray:b];
    
    [surfaces enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(IGMainAppSurfaceIntent *surface, NSUInteger idx, BOOL *stop) {
        
        NSInteger subtype = [[surface valueForKey:@"_subtype"] integerValue];
        
        if (subtype == 2 && [SCIManager getPref:@"hide_reels_tab"]) {
            [surfaces removeObjectAtIndex:idx];
        }
        
        if (subtype == 3 && [SCIManager getPref:@"hide_create_tab"]) {
            [surfaces removeObjectAtIndex:idx];
        }
    }];
    return %orig(a, surfaces, c, d);
}

%end
