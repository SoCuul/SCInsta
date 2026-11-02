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
            if ([[obj valueForKey:@"tag"] intValue] == 2) { // 2 == Suggested Users
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

// Profile "following" and "followers" tabs
%hook IGFollowListViewController
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig(arg1);
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (IGStoryTrayViewModel *obj in originalObjs) {
        BOOL shouldHide = NO;

        if ([SCIUtils getBoolPref:@"no_suggested_users"]) {

            // Suggested user
            if ([obj isKindOfClass:%c(IGDiscoverPeopleItemConfiguration)]) {
                NSLog(@"[SCInsta] Hiding suggested users: follow list suggested user");

                shouldHide = YES;
            }

            // Section header 
            else if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {

                // "Suggested for you" search results header
                if ([[obj valueForKey:@"labelTitle"] isEqualToString:@"Suggested for you"]) {
                    shouldHide = YES;
                }

            }

            // See all suggested users
            else if ([obj isKindOfClass:%c(IGSeeAllItemConfiguration)] && ((IGSeeAllItemConfiguration *)obj).destination == 4) {
                NSLog(@"[SCInsta] Hiding suggested users: follow list suggested user");

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

// Suggested subscriptions
%hook IGFanClubSuggestedUsersDataSource
- (id)initWithUserSession:(id)arg1 delegate:(id)arg2 {
    if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
        return nil;
    }

    return %orig(arg1, arg2);
}
%end

// Follow request/discover section (accessed through notifications page)
// Demangled name: IGFriendingCenter.IGFriendingCenterViewController
%hook _TtC17IGFriendingCenter31IGFriendingCenterViewController
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig(arg1);
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (IGStoryTrayViewModel *obj in originalObjs) {
        BOOL shouldHide = NO;

        if ([SCIUtils getBoolPref:@"no_suggested_users"]) {

            // Suggested user
            if ([obj isKindOfClass:%c(IGDiscoverPeopleItemConfiguration)]) {
                NSLog(@"[SCInsta] Hiding suggested users: follow list suggested user");

                shouldHide = YES;
            }

            // Section header 
            else if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {

                // "Suggested for you" search results header
                if ([[obj valueForKey:@"labelTitle"] isEqualToString:@"Suggested for you"]) {
                    shouldHide = YES;
                }

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

%hook IGProfileActionBarViewModel
- (id)initWithIdentifier:(id)arg1
                    rows:(id)arg2
     allActionsToDisplay:(id)arg3
         overflowActions:(id)arg4
    actionToBadgeInfoMap:(id)arg5
      allBusinessActions:(id)arg6
 overflowBusinessActions:(id)arg7
     contactSheetActions:(id)arg8
                    user:(id)arg9
   sponsoredInfoProvider:(id)arg10
  profileBackgroundColor:(id)arg11
{
    NSArray *rows = arg2;
    NSOrderedSet *allActions = [arg3 copy];
    NSOrderedSet *overflowActions = [arg4 copy];

    if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", @[ @(3) ]];
        
        // Actions sets
        allActions = [allActions filteredOrderedSetUsingPredicate:predicate];
        overflowActions = [overflowActions filteredOrderedSetUsingPredicate:predicate];

        // Rows of actions sets
        NSMutableArray *filteredRows = [NSMutableArray new];
        for (NSOrderedSet *set in rows) {
            [filteredRows addObject:[set filteredOrderedSetUsingPredicate:predicate]];
        }
        rows = [filteredRows copy];
    }

    return %orig(arg1, rows, allActions, overflowActions, arg5, arg6, arg7, arg8, arg9, arg10, arg11);
}
%end