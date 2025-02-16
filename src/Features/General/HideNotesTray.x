#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Disable notes data source
%hook IGDirectNotesModelsDataSource

- (id)initWithUserSession:(id)arg1 {
    if ([SCIManager getPref:@"hide_notes_tray"]) {
        NSLog(@"[SCInsta] Hide notes tray");
        return nil;
    }

    return %orig;
}

%end