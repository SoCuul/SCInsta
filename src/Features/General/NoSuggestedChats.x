#import "../../Utils.h"
#import "../../InstagramHeaders.h"

// Channels dms tab (header)
%hook IGDirectInboxHeaderSectionController
- (id)viewModel {
    if ([[%orig title] isEqualToString:@"Suggested"]) {

        if ([SCIUtils getBoolPref:@"no_suggested_chats"]) {
            NSLog(@"[SCInsta] Hiding suggested chats (header: channels tab)");

            return nil;
        }

    }

    return %orig;
}
%end