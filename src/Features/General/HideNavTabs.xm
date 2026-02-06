#import "../../Utils.h"
#import "../../InstagramHeaders.h"

BOOL isSurfaceShown(IGMainAppSurfaceIntent *surface) {
    BOOL isShown = YES;

    // Feed
    if ([[surface tabStringFromSurfaceIntent] isEqualToString:@"FEED"] && [SCIUtils getBoolPref:@"hide_feed_tab"]) {
        isShown = NO;
    }
    
    // Reels
    else if ([[surface tabStringFromSurfaceIntent] isEqualToString:@"CLIPS"] && [SCIUtils getBoolPref:@"hide_reels_tab"]) {
        isShown = NO;
    }

    // Explore
    else if ([[surface tabStringFromSurfaceIntent] isEqualToString:@"SEARCH"] && [SCIUtils getBoolPref:@"hide_explore_tab"]) {
        isShown = NO;
    }

    // Create
    else if ([(NSNumber *)[surface valueForKey:@"_subtype"] unsignedIntegerValue] == 3 && [SCIUtils getBoolPref:@"hide_create_tab"]) {
        isShown = NO;
    }

    return isShown;
}

NSArray *filterSurfacesArray(NSArray *surfaces) {
    NSMutableArray *filteredSurfaces = [NSMutableArray array];

    for (IGMainAppSurfaceIntent *surface in surfaces) {
        if (![surface isKindOfClass:%c(IGMainAppSurfaceIntent)]) break;

        if (isSurfaceShown(surface)) {
            [filteredSurfaces addObject:surface];
        }
    }

    return filteredSurfaces;
}

///////////////////////////////////////////////

%hook IGTabBarControllerSwipeCoordinator
- (id)initWithSurfaces:(id)surfaces parentViewController:(id)controller enableHaptics:(_Bool)haptics launcherSet:(id)set {
    // Removes the surface from the main swipeable app collection view
    return %orig(filterSurfacesArray(surfaces), controller, haptics, set);
}
%end

%hook IGTabBarController
- (void)_layoutTabBar {
    // Prevents the wrong icon from being shown as selected because of mismatched surface array indexes
    NSArray *_tabBarSurfaces = MSHookIvar<NSArray *>(self, "_tabBarSurfaces");

    Ivar ivar = class_getInstanceVariable(object_getClass(self), "_tabBarSurfaces");
    object_setIvarWithStrongDefault(self, ivar, filterSurfacesArray(_tabBarSurfaces));
    
    %orig;
}

- (id)_buttonForTabBarSurface:(id)surface {
    // Prevents the button from being added to the tab bar 
    id button = %orig(surface);

    if (!isSurfaceShown(surface)) {
        return nil;
    }

    return button;
}
%end