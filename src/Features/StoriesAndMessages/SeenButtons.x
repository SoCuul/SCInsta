#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import "../../Tweak.h"
#import "../../Utils.h"

// Seen buttons (in DMs)
// - Enables no seen for messages
// - Enables unlimited views of DM visual messages
%hook IGTallNavigationBarView
- (void)setRightBarButtonItems:(NSArray <UIBarButtonItem *> *)items {
    NSMutableArray *new_items = [items mutableCopy];

    // Messages seen
    if ([SCIManager getBoolPref:@"remove_lastseen"]) {
        UIBarButtonItem *seenButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.message"] style:UIBarButtonItemStylePlain target:self action:@selector(seenButtonHandler:)];
        [new_items addObject:seenButton];

        if (seenButtonEnabled) {
            [seenButton setTintColor:SCIUtils.SCIColor_Primary];
        } else {
            [seenButton setTintColor:UIColor.labelColor];
        }
    }

    // DM visual messages viewed
    if ([SCIManager getBoolPref:@"unlimited_replay"]) {
        UIBarButtonItem *dmVisualMsgsViewedButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"photo.badge.checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(dmVisualMsgsViewedButtonHandler:)];
        [new_items addObject:dmVisualMsgsViewedButton];

        if (dmVisualMsgsViewedButtonEnabled) {
            [dmVisualMsgsViewedButton setTintColor:SCIUtils.SCIColor_Primary];
        } else {
            [dmVisualMsgsViewedButton setTintColor:UIColor.labelColor];
        }
    }

    %orig([new_items copy]);
}

// Messages seen button
%new - (void)seenButtonHandler:(UIBarButtonItem *)sender {
    if (seenButtonEnabled) {
        seenButtonEnabled = false;
        [sender setTintColor:UIColor.labelColor];
    } else {
        seenButtonEnabled = true;
        [sender setTintColor:SCIUtils.SCIColor_Primary];
    }
}
// DM visual messages viewed button
%new - (void)dmVisualMsgsViewedButtonHandler:(UIBarButtonItem *)sender {
    if (dmVisualMsgsViewedButtonEnabled) {
        dmVisualMsgsViewedButtonEnabled = false;
        [sender setTintColor:UIColor.labelColor];
    } else {
        dmVisualMsgsViewedButtonEnabled = true;
        [sender setTintColor:SCIUtils.SCIColor_Primary];
    }
}
%end

// Messages seen logic
%hook IGDirectThreadViewListAdapterDataSource
- (BOOL)shouldUpdateLastSeenMessage {
    if ([SCIManager getBoolPref:@"remove_lastseen"]) {
        // Check if messages should be shown as seen
        if (seenButtonEnabled) {
            return %orig;
        }
        
        return false;
    }
    
    return %orig;
}
%end

// DM stories viewed logic
%hook IGDirectVisualMessageViewerEventHandler
- (void)visualMessageViewerController:(id)arg1 didBeginPlaybackForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 {
    if ([SCIManager getBoolPref:@"unlimited_replay"]) {
        // Check if dm stories should be marked as viewed
        if (dmVisualMsgsViewedButtonEnabled) {
            %orig;
        }
    }
}
- (void)visualMessageViewerController:(id)arg1 didEndPlaybackForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 mediaCurrentTime:(CGFloat)arg4 forNavType:(NSInteger)arg5 {
    if ([SCIManager getBoolPref:@"unlimited_replay"]) {
        // Check if dm stories should be marked as viewed
        if (dmVisualMsgsViewedButtonEnabled) {
            %orig;
        }
    }
}
%end