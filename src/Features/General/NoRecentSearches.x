#import "../../Utils.h"
#import "../../InstagramHeaders.h"

// Disable logging of searches at server-side
%hook IGSearchEntityRouter
- (id)initWithUserSession:(id)arg1 analyticsModule:(id)arg2 shouldAddToRecents:(BOOL)shouldAddToRecents {
    if ([SCIUtils getBoolPref:@"no_recent_searches"]) {
        NSLog(@"[SCInsta] Disabling recent searches");

        shouldAddToRecents = false;
    }
    
    return %orig(arg1, arg2, shouldAddToRecents);
}
%end

// Most in-app search bars
%hook IGRecentSearchStore
- (id)initWithDiskManager:(id)arg1 recentSearchStoreConfiguration:(id)arg2 {
    if ([SCIUtils getBoolPref:@"no_recent_searches"]) {
        NSLog(@"[SCInsta] Disabling recent searches");

        return nil;
    }

    return %orig;
}
- (BOOL)addItem:(id)arg1 {
    if ([SCIUtils getBoolPref:@"no_recent_searches"]) {
        NSLog(@"[SCInsta] Disabling recent searches");

        return nil;
    }

    return %orig;
}
%end

// Recent dm message recipients search bar
%hook IGDirectRecipientRecentSearchStorage
- (id)initWithDiskManager:(id)arg1 directRepo:(id)arg2 userMap:(id)arg3 currentUser:(id)arg4 launcherSet:(id)arg5 {
    if ([SCIUtils getBoolPref:@"no_recent_searches"]) {
        NSLog(@"[SCInsta] Disabling recent searches");

        return nil;
    }

    return %orig(arg1, arg2, arg3, arg4, arg5);
}
%end