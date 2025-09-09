#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Channels dms tab (header)
%hook IGDirectInboxHeaderSectionController
- (id)viewModel {
    if ([[%orig title] isEqualToString:@"Suggested"]) {

        if ([SCIManager getBoolPref:@"no_suggested_chats"]) {
            NSLog(@"[SCInsta] Hiding suggested chats (header: channels tab)");

            return nil;
        }

    }

    return %orig;
}
%end