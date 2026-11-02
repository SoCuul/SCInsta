#import "../../Utils.h"

%hook IGSundialViewerVerticalUFI
- (void)setNumLikes:(NSInteger)num {
    return %orig([SCIUtils getBoolPref:@"hide_metrics"] ? 0 : num);
}
- (void)setNumReshares:(NSInteger)num {
    return %orig([SCIUtils getBoolPref:@"hide_metrics"] ? 0 : num);
}
- (void)setNumComments:(NSInteger)num {
    return %orig([SCIUtils getBoolPref:@"hide_metrics"] ? 0 : num);
}
- (void)setNumReposts:(NSInteger)num {
    return %orig([SCIUtils getBoolPref:@"hide_metrics"] ? 0 : num);
}
- (void)setNumSaves:(NSInteger)num {
    return %orig([SCIUtils getBoolPref:@"hide_metrics"] ? 0 : num);
}
%end

%hook IGUFIButtonWithCountsView
- (void)setCountString:(id)string showButton:(BOOL)showButton {
    return %orig([SCIUtils getBoolPref:@"hide_metrics"] ? @"" : string, showButton);
}
%end