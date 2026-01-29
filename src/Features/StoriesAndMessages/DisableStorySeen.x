#import "../../Utils.h"
#import "../../InstagramHeaders.h"

%hook IGStorySeenStateUploader
- (id)initWithUserSessionPK:(id)arg1 networker:(id)arg2 {
    if ([SCIUtils getBoolPref:@"no_seen_receipt"]) {
        NSLog(@"[SCInsta] Prevented seen receipt from being sent");

        return nil;
    }
    
    return %orig;
}

- (id)networker {
    if ([SCIUtils getBoolPref:@"no_seen_receipt"]) {
        NSLog(@"[SCInsta] Prevented seen receipt from being sent");

        return nil;
    }
    
    return %orig;
}
%end