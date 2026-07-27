#import "../../InstagramHeaders.h"
#import "../../Tweak.h"
#import "../../Utils.h"

// Seen buttons (in DMs)
// - Enables no seen for messages
// - Enables unlimited views of DM visual messages

%hook IGTallNavigationBarView

- (void)setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)items {
    NSArray<UIBarButtonItem *> *originalItems = items ?: @[];

    NSMutableArray<UIBarButtonItem *> *newItems = [[originalItems filteredArrayUsingPredicate:
        [NSPredicate predicateWithBlock:^BOOL(UIBarButtonItem *value, NSDictionary *bindings) {
            if (![value isKindOfClass:[UIBarButtonItem class]]) {
                return YES;
            }

            if ([SCIUtils getBoolPref:@"hide_reels_blend"]) {
                return ![value.accessibilityIdentifier isEqualToString:@"blend-button"];
            }

            return YES;
        }]
    ] mutableCopy];

    // Messages seen
    if (!newItems) {
        newItems = [NSMutableArray array];
    }

    // Messages seen button
    if ([SCIUtils getBoolPref:@"remove_lastseen"]) {
        BOOL alreadyHasSeenButton = NO;

        for (UIBarButtonItem *item in newItems) {
            if (item.action == @selector(seenButtonHandler:)) {
                alreadyHasSeenButton = YES;
                break;
            }
        }

        if (!alreadyHasSeenButton) {
            UIBarButtonItem *seenButton = [[UIBarButtonItem alloc]
                initWithImage:[UIImage systemImageNamed:@"checkmark.message"]
                        style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(seenButtonHandler:)];
            [newItems addObject:seenButton];
        }
    }

    // DM visual messages viewed button
    if ([SCIUtils getBoolPref:@"unlimited_replay"]) {
        BOOL alreadyHasReplayButton = NO;

        for (UIBarButtonItem *item in newItems) {
            if (item.action == @selector(dmVisualMsgsViewedButtonHandler:)) {
                alreadyHasReplayButton = YES;
                break;
            }
        }

        if (!alreadyHasReplayButton) {
            UIBarButtonItem *dmVisualMsgsViewedButton = [[UIBarButtonItem alloc]
                initWithImage:[UIImage systemImageNamed:@"photo.badge.checkmark"]
                        style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(dmVisualMsgsViewedButtonHandler:)];

            dmVisualMsgsViewedButton.tintColor = dmVisualMsgsViewedButtonEnabled
                ? SCIUtils.SCIColor_Primary
                : UIColor.labelColor;

            [newItems addObject:dmVisualMsgsViewedButton];
        }
    }

    %orig([newItems copy]);
}
// Messages seen button
%new
- (void)seenButtonHandler:(UIBarButtonItem *)sender {
    UIViewController *nearestVC = [SCIUtils nearestViewControllerForView:self];
    if ([nearestVC isKindOfClass:%c(IGDirectThreadViewController)]) {
        [(IGDirectThreadViewController *)nearestVC markLastMessageAsSeen];
        [SCIUtils showToastForDuration:2.5 title:@"Marked messages as seen"];
    }
}
// DM visual messages viewed button
%new
- (void)dmVisualMsgsViewedButtonHandler:(UIBarButtonItem *)sender {
    dmVisualMsgsViewedButtonEnabled = !dmVisualMsgsViewedButtonEnabled;

    sender.tintColor = dmVisualMsgsViewedButtonEnabled
        ? SCIUtils.SCIColor_Primary
        : UIColor.labelColor;

    if (dmVisualMsgsViewedButtonEnabled) {
        [SCIUtils showToastForDuration:4.5 title:@"Visual messages will now expire after viewing"];
    } else {
        [SCIUtils showToastForDuration:4.5 title:@"Visual messages can be replayed without expiring"];
    }
}

%end

// Messages seen logic
%hook IGDirectThreadViewListAdapterDataSource

- (BOOL)shouldUpdateLastSeenMessage {
    if ([SCIUtils getBoolPref:@"remove_lastseen"]) {
        return NO;
    }

    return %orig;
}

%end

// DM stories viewed logic
%hook IGDirectVisualMessageViewerEventHandler

- (void)visualMessageViewerController:(id)arg1
didBeginPlaybackForVisualMessage:(id)arg2
                             atIndex:(NSInteger)arg3 {
    if (![SCIUtils getBoolPref:@"unlimited_replay"]) {
        %orig;
        return;
    }

    if (dmVisualMsgsViewedButtonEnabled) {
        %orig;
    }
}

- (void)visualMessageViewerController:(id)arg1
didEndPlaybackForVisualMessage:(id)arg2
                             atIndex:(NSInteger)arg3
                    mediaCurrentTime:(CGFloat)arg4
                          forNavType:(NSInteger)arg5 {
    if (![SCIUtils getBoolPref:@"unlimited_replay"]) {
        %orig;
        return;
    }

    if (dmVisualMsgsViewedButtonEnabled) {
        %orig;
    }
}

%end