#import <substrate.h>
#import "../../Utils.h"

// NOTE: Logos' bare %orig substitution corrupts the surrounding braces when
// used inside a nested block literal (e.g. inside a showConfirmation
// completion handler), so the reel-refresh confirmation hook below is
// implemented manually via MSHookMessageEx with a captured C function
// pointer instead of %hook/%orig.
static void (*orig_refreshReelsWithParamsForNetworkRequest)(id, SEL, NSInteger, BOOL);
static void hooked_refreshReelsWithParamsForNetworkRequest(id self, SEL _cmd, NSInteger arg1, BOOL arg2) {
    if ([SCIUtils getBoolPref:@"prevent_doom_scrolling"]) {
        IGRefreshControl *_refreshControl = MSHookIvar<IGRefreshControl *>(self, "_refreshControl");
        [self refreshControlDidEndFinishLoadingAnimation:_refreshControl];

        return;
    }

    if ([SCIUtils getBoolPref:@"refresh_reel_confirm"]) {
        NSLog(@"[SCInsta] Reel refresh triggered");

        [SCIUtils showConfirmation:^(void) {
            orig_refreshReelsWithParamsForNetworkRequest(self, _cmd, arg1, arg2);
        }
                     cancelHandler:^(void) {
                         IGRefreshControl *_refreshControl = MSHookIvar<IGRefreshControl *>(self, "_refreshControl");
                         [self refreshControlDidEndFinishLoadingAnimation:_refreshControl];
                     }
                             title:@"Refresh Reels"];
    } else {
        orig_refreshReelsWithParamsForNetworkRequest(self, _cmd, arg1, arg2);
    }
}

%ctor {
    Class cls = objc_getClass("IGSundialFeedViewController");
    if (!cls) return;

    MSHookMessageEx(cls, @selector(_refreshReelsWithParamsForNetworkRequest:userDidPullToRefresh:), (IMP)hooked_refreshReelsWithParamsForNetworkRequest, (IMP *)&orig_refreshReelsWithParamsForNetworkRequest);
}

%hook IGSundialPlaybackControlsTestConfiguration
- (id)initWithLauncherSet:(id)set
                     tapToPauseEnabled:(_Bool)tapPauseEnabled
      combineSingleTapPlaybackControls:(_Bool)controls
        isVideoPreviewThumbnailEnabled:(_Bool)previewThumbEnabled
                minScrubberDurationSec:(long long)minSec
         seekResumeScrubberCooldownSec:(double)seekSec
          tapResumeScrubberCooldownSec:(double)tapSec
    persistentScrubberMinVideoDuration:(long long)duration
        isScrubberForShortVideoEnabled:(_Bool)shortScrubberEnabled
{
    _Bool userTapPauseEnabled = tapPauseEnabled;
    if ([[SCIUtils getStringPref:@"reels_tap_control"] isEqualToString:@"pause"]) userTapPauseEnabled = true;
    else if ([[SCIUtils getStringPref:@"reels_tap_control"] isEqualToString:@"mute"]) userTapPauseEnabled = false;

    long long userMinSec = minSec;
    long long userDuration = duration;
    _Bool userShortScrubberEnabled = shortScrubberEnabled;
    if ([SCIUtils getBoolPref:@"reels_show_scrubber"]) {
        userMinSec = 0;
        userDuration = 0;
        userShortScrubberEnabled = true;
    }

    return %orig(set, userTapPauseEnabled, controls, previewThumbEnabled, userMinSec, seekSec, tapSec, userDuration, userShortScrubberEnabled);
}
%end

// * Disable volume/mute button triggering unmutes
%hook IGAudioStatusAnnouncer
- (void)_muteSwitchStateChanged:(id)changed {
    if (![SCIUtils getBoolPref:@"disable_auto_unmuting_reels"]) {
        %orig(changed);
    }
}
- (void)_didPressVolumeButton:(id)button {
    if (![SCIUtils getBoolPref:@"disable_auto_unmuting_reels"]) {
        %orig(button);
    }
}
- (void)_didUnplugHeadphones:(id)headphones {
    if (![SCIUtils getBoolPref:@"disable_auto_unmuting_reels"]) {
        %orig(headphones);
    }
}
%end