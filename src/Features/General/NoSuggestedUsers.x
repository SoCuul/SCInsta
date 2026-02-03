#import "../../Utils.h"
#import "../../InstagramHeaders.h"

// "Welcome to instagram" suggested users in feed
%hook IGSuggestedUnitViewModel
- (id)initWithAYMFModel:(id)arg1 headerViewModel:(id)arg2 {
    if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
        NSLog(@"[SCInsta] Hiding suggested users: main feed welcome section");

        return nil;
    }

    return %orig;
}
%end
%hook IGSuggestionsUnitViewModel
- (id)initWithAYMFModel:(id)arg1 headerViewModel:(id)arg2 {
    if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
        NSLog(@"[SCInsta] Hiding suggested users: main feed welcome section");

        return nil;
    }

    return %orig;
} 
%end

// Suggested users in profile header
%hook IGProfileHeaderView
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
            if ([obj isKindOfClass:%c(IGProfileChainingModel)]) {
                NSLog(@"[SCInsta] Hiding suggested users: profile header");

                shouldHide = YES;
            }
        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }
    }

    return [filteredObjs copy];
}
%end

// Notifications/activity feed
%hook IGActivityFeedViewController
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        // Section header 
        if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {
            // Suggested for you
            if ([[obj labelTitle] isEqualToString:@"Suggested for you"]) {
                if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
                    NSLog(@"[SCInsta] Hiding suggested users (header: activity feed)");

                    shouldHide = YES;
                }
            }
        }

        // Suggested user
        else if ([obj isKindOfClass:%c(IGDiscoverPeopleItemConfiguration)]) {
            if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
                NSLog(@"[SCInsta] Hiding suggested users: (user: activity feed)");

                shouldHide = YES;
            }
        }

        // "See all" button
        else if ([obj isKindOfClass:%c(IGSeeAllItemConfiguration)]) {
            if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
                NSLog(@"[SCInsta] Hiding suggested users: (see all: activity feed)");

                shouldHide = YES;
            }
        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }
    }

    return [filteredObjs copy];
}
%end

// Story tray
%hook IGMainStoryTrayDataSource
- (id)allItemsForTrayUsingCachedValue:(BOOL)cached {
    NSArray *originalObjs = %orig(cached);
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (IGStoryTrayViewModel *obj in originalObjs) {
        BOOL shouldHide = NO;

        if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
            // This hides as many recommended models as possible, without hiding genuine models
            // Most recommended models share a 32 digit id, unlike normal accounts
            if ([obj isKindOfClass:%c(IGStoryTrayViewModel)] && [obj.pk length] == 32) {
                NSLog(@"[SCInsta] Hiding suggested users: story tray");

                shouldHide = YES;
            }
        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }
    }

    return [filteredObjs copy];
}
%end

%hook IGFollowListViewControllerConfiguration
- (BOOL)showSuggestedUsers {
    return NO;
}
%end

%hook IGSegmentedTabControl
- (void)setSegments:(id)segments {
    NSArray *originalObjs = segments;
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (IGStoryTrayViewModel *obj in originalObjs) {
        BOOL shouldHide = NO;

        if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
            if ([obj isKindOfClass:%c(IGFindUsersViewController)]) {
                NSLog(@"[SCInsta] Hiding suggested users: find users segmented tab");

                shouldHide = YES;
            }
        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }
    }

    return %orig([filteredObjs copy]);
}
%end