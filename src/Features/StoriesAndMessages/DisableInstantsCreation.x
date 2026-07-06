#import "../../Utils.h"

// Demangled name: IGQuickSnapExperimentation.IGQuickSnapExperimentationHelper
%hook _TtC26IGQuickSnapExperimentation32IGQuickSnapExperimentationHelper
+ (_Bool)isQuicksnapEnabled:(id)enabled {
    if ([SCIUtils getBoolPref:@"disable_instants_creation"]) {
        return false;
    }
    return %orig(enabled);
}
+ (_Bool)isQuicksnapEnabledInFeed:(id)feed {
    if ([SCIUtils getBoolPref:@"disable_instants_creation"]) {
        return false;
    }
    return %orig(feed);
}
+ (_Bool)isQuicksnapEnabledInInbox:(id)inbox {
    if ([SCIUtils getBoolPref:@"disable_instants_creation"]) {
        return false;
    }
    return %orig(inbox);
}
+ (_Bool)isQuicksnapEnabledInStories:(id)stories {
    if ([SCIUtils getBoolPref:@"disable_instants_creation"]) {
        return false;
    }
    return %orig(stories);
}
+ (_Bool)isQuicksnapEnabledInNotesTray:(id)tray {
    if ([SCIUtils getBoolPref:@"disable_instants_creation"]) {
        return false;
    }
    return %orig(tray);
}
+ (_Bool)isQuicksnapEnabledInNotesTrayWithPeek:(id)peek {
    if ([SCIUtils getBoolPref:@"disable_instants_creation"]) {
        return false;
    }
    return %orig(peek);
}
+ (_Bool)isQuicksnapEnabledInNotesTrayWithPog:(id)pog {
    if ([SCIUtils getBoolPref:@"disable_instants_creation"]) {
        return false;
    }
    return %orig(pog);
}
+ (_Bool)isQuicksnapNotesTrayEmptyPogEnabled:(id)enabled {
    if ([SCIUtils getBoolPref:@"disable_instants_creation"]) {
        return false;
    }
    return %orig(enabled);
}
// + (_Bool)isStoriesSpringEnabled:(id)enabled {
//     return true;
// }
// + (_Bool)shouldEnableScreenshotBlocking:(id)blocking {
//     return false;
// }
// + (_Bool)areFiltersEnabled:(id)enabled {
//     return true;
// }
// + (_Bool)isBottomsheetCustomAudienceEnabled:(id)enabled {
//     return true;
// }
// + (_Bool)isVideoCaptureEnabled:(id)enabled {
//     return true;
// }
%end

// %hook IGDirectNotesTrayRowCell
// - (_Bool)isQuicksnapPeekVisible {
//     return true;
// }
// %end

// %hook IGDirectNotesTrayRowSectionController
// - (_Bool)isQuicksnapPeekVisible {
//     return true;
// }
// %end
