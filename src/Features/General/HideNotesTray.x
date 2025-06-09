#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Disable notes tray data source
%hook IGDirectNotesModelsDataSource
- (id)initWithUserSession:(id)arg1 {
    if ([SCIManager getPref:@"hide_notes_tray"]) {
        NSLog(@"[SCInsta] Hide notes tray");
        return nil;
    }

    return %orig;
}
%end

// Remove notes tray
%hook IGDirectNotesTrayRowSectionController
- (id)initWithUserSession:(id)arg1 delegate:(id)arg2 containerModule:(id)arg3 {
    if ([SCIManager getPref:@"hide_notes_tray"]) {
        NSLog(@"[SCInsta] Hiding notes tray");
        return nil;
    }
    return %orig(arg1, arg2, arg3);
}
%end