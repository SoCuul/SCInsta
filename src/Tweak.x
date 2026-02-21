#import <substrate.h>
#import "InstagramHeaders.h"
#import "Tweak.h"
#import "Utils.h"
#import "Settings/SCISettingsViewController.h"

///////////////////////////////////////////////////////////

// Screenshot handlers

#define VOID_HANDLESCREENSHOT(orig) [SCIUtils getBoolPref:@"remove_screenshot_alert"] ? nil : orig;
#define NONVOID_HANDLESCREENSHOT(orig) return VOID_HANDLESCREENSHOT(orig)

///////////////////////////////////////////////////////////

// * Tweak version *
NSString *SCIVersionString = @"v1.0.1-beta";

// Variables that work across features
BOOL dmVisualMsgsViewedButtonEnabled = false;

// Tweak first-time setup
%hook IGInstagramAppDelegate
- (_Bool)application:(UIApplication *)application willFinishLaunchingWithOptions:(id)arg2 {
    // Default SCInsta config
    NSDictionary *sciDefaults = @{
        @"hide_ads": @(YES),
        @"copy_description": @(YES),
        @"detailed_color_picker": @(YES),
        @"remove_screenshot_alert": @(YES),
        @"call_confirm": @(YES),
        @"keep_deleted_message": @(YES),
        @"dw_feed_posts": @(YES),
        @"dw_reels": @(YES),
        @"dw_story": @(YES),
        @"save_profile": @(YES),
        @"dw_finger_count": @(3),
        @"dw_finger_duration": @(0.5),
        @"reels_tap_control": @"default",
        @"nav_icon_ordering": @"default",
        @"swipe_nav_tabs": @"default",
        @"enable_notes_customization": @(YES),
        @"custom_note_themes": @(YES),
        @"disable_auto_unmuting_reels": @(YES)
    };
    [[NSUserDefaults standardUserDefaults] registerDefaults:sciDefaults];
    
    // Override instagram defaults
    if ([SCIUtils getBoolPref:@"liquid_glass_buttons"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"instagram.override.project.lucent.navigation"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"instagram.override.project.lucent.navigation"];
    }

    return %orig;
}
- (_Bool)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)arg2 {
    %orig;

    // Open settings for first-time users
    double openDelay = [SCIUtils getBoolPref:@"tweak_settings_app_launch"] ? 0.0 : 5.0;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(openDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (
            ![[[NSUserDefaults standardUserDefaults] objectForKey:@"SCInstaFirstRun"] isEqualToString:SCIVersionString]
            || [SCIUtils getBoolPref:@"tweak_settings_app_launch"]
        ) {
            NSLog(@"[SCInsta] First run, initializing");

            // Display settings modal on screen
            NSLog(@"[SCInsta] Displaying SCInsta first-time settings modal");
            UIViewController *rootController = [[self window] rootViewController];
            SCISettingsViewController *settingsViewController = [SCISettingsViewController new];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];

            [rootController presentViewController:navigationController animated:YES completion:nil];
        }
    });

    NSLog(@"[SCInsta] Cleaning cache...");
    [SCIUtils cleanCache];

    if ([SCIUtils getBoolPref:@"flex_app_launch"]) {
        [[objc_getClass("FLEXManager") sharedManager] showExplorer];
    }

    return true;
}

- (void)applicationDidBecomeActive:(id)arg1 {
    %orig;
    
    if ([SCIUtils getBoolPref:@"flex_app_start"]) {
        [[objc_getClass("FLEXManager") sharedManager] showExplorer];
    }
}
%end

%hook IGDSLauncherConfig
- (_Bool)isLiquidGlassInAppNotificationEnabled {
    return [SCIUtils liquidGlassEnabledBool:%orig];
}
- (_Bool)isLiquidGlassContextMenuEnabled{
    return [SCIUtils liquidGlassEnabledBool:%orig];
}
- (_Bool)isLiquidGlassToastEnabled {
    return [SCIUtils liquidGlassEnabledBool:%orig];
}
- (_Bool)isLiquidGlassToastPeekEnabled {
    return [SCIUtils liquidGlassEnabledBool:%orig];
}
- (_Bool)isLiquidGlassAlertDialogEnabled {
    return [SCIUtils liquidGlassEnabledBool:%orig];
}
%end

// Disable sending modded insta bug reports
%hook IGWindow
- (void)showDebugMenu {
    return;
}
%end

%hook IGBugReportUploader
- (id)initWithNetworker:(id)arg1
         pandoGraphQLService:(id)arg2
             analyticsLogger:(id)arg3
                userDefaults:(id)arg4
         launcherSetProvider:(id)arg5
shouldPersistLastBugReportId:(id)arg6
{
    return nil;
}
%end

// Disable anti-screenshot feature on visual messages
%hook IGStoryViewerContainerView
- (void)setShouldBlockScreenshot:(BOOL)arg1 viewModel:(id)arg2 { VOID_HANDLESCREENSHOT(%orig); }
%end

// Disable screenshot logging/detection
%hook IGDirectVisualMessageViewerSession
- (id)visualMessageViewerController:(id)arg1 didDetectScreenshotForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 { NONVOID_HANDLESCREENSHOT(%orig); }
%end

%hook IGDirectVisualMessageReplayService
- (id)visualMessageViewerController:(id)arg1 didDetectScreenshotForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 { NONVOID_HANDLESCREENSHOT(%orig); }
%end

%hook IGDirectVisualMessageReportService
- (id)visualMessageViewerController:(id)arg1 didDetectScreenshotForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 { NONVOID_HANDLESCREENSHOT(%orig); }
%end

%hook IGDirectVisualMessageScreenshotSafetyLogger
- (id)initWithUserSession:(id)arg1 entryPoint:(NSInteger)arg2 {
    if ([SCIUtils getBoolPref:@"remove_screenshot_alert"]) {
        NSLog(@"[SCInsta] Disable visual message screenshot safety logger");
        return nil;
    }

    return %orig;
}
%end

%hook IGScreenshotObserver
- (id)initForController:(id)arg1 { NONVOID_HANDLESCREENSHOT(%orig); }
%end

%hook IGScreenshotObserverDelegate
- (void)screenshotObserverDidSeeScreenshotTaken:(id)arg1 { VOID_HANDLESCREENSHOT(%orig); }
- (void)screenshotObserverDidSeeActiveScreenCapture:(id)arg1 event:(NSInteger)arg2 { VOID_HANDLESCREENSHOT(%orig); }
%end

%hook IGDirectMediaViewerViewController
- (void)screenshotObserverDidSeeScreenshotTaken:(id)arg1 { VOID_HANDLESCREENSHOT(%orig); }
- (void)screenshotObserverDidSeeActiveScreenCapture:(id)arg1 event:(NSInteger)arg2 { VOID_HANDLESCREENSHOT(%orig); }
%end

%hook IGStoryViewerViewController
- (void)screenshotObserverDidSeeScreenshotTaken:(id)arg1 { VOID_HANDLESCREENSHOT(%orig); }
- (void)screenshotObserverDidSeeActiveScreenCapture:(id)arg1 event:(NSInteger)arg2 { VOID_HANDLESCREENSHOT(%orig); }
%end

%hook IGSundialFeedViewController
- (void)screenshotObserverDidSeeScreenshotTaken:(id)arg1 { VOID_HANDLESCREENSHOT(%orig); }
- (void)screenshotObserverDidSeeActiveScreenCapture:(id)arg1 event:(NSInteger)arg2 { VOID_HANDLESCREENSHOT(%orig); }
%end

%hook IGDirectVisualMessageViewerController
- (void)screenshotObserverDidSeeScreenshotTaken:(id)arg1 { VOID_HANDLESCREENSHOT(%orig); }
- (void)screenshotObserverDidSeeActiveScreenCapture:(id)arg1 event:(NSInteger)arg2 { VOID_HANDLESCREENSHOT(%orig); }
%end

/////////////////////////////////////////////////////////////////////////////

// Hide items

// Direct suggested chats (in search bar)
%hook IGDirectInboxSearchListAdapterDataSource
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        // Section header 
        if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {

            // Broadcast channels
            if ([[obj valueForKey:@"uniqueIdentifier"] isEqualToString:@"channels"]) {
                if ([SCIUtils getBoolPref:@"no_suggested_chats"]) {
                    NSLog(@"[SCInsta] Hiding suggested chats (header)");

                    shouldHide = YES;
                }
            }

            // Ask Meta AI
            else if ([[obj valueForKey:@"labelTitle"] isEqualToString:@"Ask Meta AI"]) {
                if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding meta ai suggested chats (header)");

                    shouldHide = YES;
                }
            }

            // AI
            else if ([[obj valueForKey:@"labelTitle"] isEqualToString:@"AI"]) {
                if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding ai suggested chats (header)");

                    shouldHide = YES;
                }
            }
            
        }

        // AI agents section
        else if (
            [obj isKindOfClass:%c(IGDirectInboxSearchAIAgentsPillsSectionViewModel)]
         || [obj isKindOfClass:%c(IGDirectInboxSearchAIAgentsSuggestedPromptViewModel)]
         || [obj isKindOfClass:%c(IGDirectInboxSearchAIAgentsSuggestedPromptLoggingViewModel)]
        ) {

            if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
                NSLog(@"[SCInsta] Hiding suggested chats (ai agents)");

                shouldHide = YES;
            }

        }

        // Recipients list
        else if ([obj isKindOfClass:%c(IGDirectRecipientCellViewModel)]) {

            // Broadcast channels
            if ([[obj recipient] isBroadcastChannel]) {
                if ([SCIUtils getBoolPref:@"no_suggested_chats"]) {
                    NSLog(@"[SCInsta] Hiding suggested chats (broadcast channels recipient)");

                    shouldHide = YES;
                }
            }
            
            // Meta AI (special section types)
            else if (([obj sectionType] == 20) || [obj sectionType] == 18) {
                if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding meta ai suggested chats (meta ai recipient)");

                    shouldHide = YES;
                }
            }

            // Meta AI (catch-all)
            else if ([[[obj recipient] threadName] isEqualToString:@"Meta AI"]) {
                if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding meta ai suggested chats (meta ai recipient)");

                    shouldHide = YES;
                }
            }
        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }

    }

    return [filteredObjs copy];
}
%end

// Direct suggested chats (thread creation view)
%hook IGDirectThreadCreationViewController
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        // Meta AI suggested user in direct new message view
        if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
            
            if ([obj isKindOfClass:%c(IGDirectCreateChatCellViewModel)]) {

                // "AI Chats"
                if ([[obj valueForKey:@"title"] isEqualToString:@"AI chats"]) {
                    NSLog(@"[SCInsta] Hiding meta ai: direct thread creation ai chats section");

                    shouldHide = YES;
                }

            }

            else if ([obj isKindOfClass:%c(IGDirectRecipientCellViewModel)]) {

                // Meta AI suggested user
                if ([[[obj recipient] threadName] isEqualToString:@"Meta AI"]) {
                    NSLog(@"[SCInsta] Hiding meta ai: direct thread creation ai suggestion");

                    shouldHide = YES;
                }

            }
            
        }

        // Invite friends to insta contacts upsell
        if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
            if ([obj isKindOfClass:%c(IGContactInvitesSearchUpsellViewModel)]) {
                NSLog(@"[SCInsta] Hiding suggested users: invite contacts upsell");

                shouldHide = YES;
            }
        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }
    }

    return [filteredObjs copy];
}
%end

// Direct suggested chats (inbox view)
%hook IGDirectInboxListAdapterDataSource
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        // Section header
        if ([obj isKindOfClass:%c(IGDirectInboxHeaderCellViewModel)]) {
            
            // "Suggestions" header
            if ([[obj title] isEqualToString:@"Suggestions"]) {
                if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding suggested chats (header: messages tab)");

                    shouldHide = YES;
                }
            }

            // "Accounts to follow/message" header
            else if ([[obj title] hasPrefix:@"Accounts to"]) {
                if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
                    NSLog(@"[SCInsta] Hiding suggested users: (header: inbox view)");

                    shouldHide = YES;
                }
            }

        }

        // Suggested recipients
        else if ([obj isKindOfClass:%c(IGDirectInboxSuggestedThreadCellViewModel)]) {
            if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
                NSLog(@"[SCInsta] Hiding suggested chats (recipients: channels tab)");

                shouldHide = YES;
            }
        }

        // "Accounts to follow" recipients
        else if ([obj isKindOfClass:%c(IGDiscoverPeopleItemConfiguration)] || [obj isKindOfClass:%c(IGDiscoverPeopleConnectionItemConfiguration)]) {
            if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
                NSLog(@"[SCInsta] Hiding suggested chats: (recipients: inbox view)");

                shouldHide = YES;
            }
        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }

    }

    return [filteredObjs copy];
}
%end

// Explore page results
%hook IGSearchListKitDataSource
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        // Meta AI
        if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {

            // Section header 
            if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {

                // "Ask Meta AI" search results header
                if ([[obj valueForKey:@"labelTitle"] isEqualToString:@"Ask Meta AI"]) {
                    shouldHide = YES;
                }

            }

            // Empty search bar upsell view
            else if ([obj isKindOfClass:%c(IGSearchNullStateUpsellViewModel)]) {
                shouldHide = YES;
            }

            // Meta AI search suggestions
            else if ([obj isKindOfClass:%c(IGSearchResultNestedGroupViewModel)]) {
                shouldHide = YES;
            }

            // Meta AI suggested search results
            else if ([obj isKindOfClass:%c(IGSearchResultViewModel)]) {

                // itemType 6 is meta ai suggestions
                if ([obj itemType] == 6) {
                    if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
                        shouldHide = YES;
                    }
                    
                }

                // Meta AI user account in search results
                else if ([[[obj title] string] isEqualToString:@"meta.ai"]) {
                    if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
                        shouldHide = YES;
                    }
                }

            }
            
        }

        // No suggested users
        if ([SCIUtils getBoolPref:@"no_suggested_users"]) {

            // Section header 
            if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {

                // "Suggested for you" search results header
                if ([[obj valueForKey:@"labelTitle"] isEqualToString:@"Suggested for you"]) {
                    shouldHide = YES;
                }

            }

            // Instagram users
            else if ([obj isKindOfClass:%c(IGDiscoverPeopleItemConfiguration)]) {
                shouldHide = YES;
            }

            // See all suggested users
            else if ([obj isKindOfClass:%c(IGSeeAllItemConfiguration)] && ((IGSeeAllItemConfiguration *)obj).destination == 4) {
                shouldHide = YES;
            }

        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }

    }

    return [filteredObjs copy];
}
%end

// Story tray
%hook IGMainStoryTrayDataSource
- (id)allItemsForTrayUsingCachedValue:(BOOL)cached {
    NSArray *originalObjs = %orig(cached);
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (IGStoryTrayViewModel *obj in originalObjs) {
        BOOL shouldHide = NO;

        if ([SCIUtils getBoolPref:@"no_suggested_users"]) {
            // This hides as many recommended models as possible, without hiding genuine models
            // Most recommended models share a 32 digit id, unlike normal accounts
            if ([obj isKindOfClass:%c(IGStoryTrayViewModel)] && [obj.pk length] == 32) {
                NSLog(@"[SCInsta] Hiding suggested users: story tray");

                shouldHide = YES;
            }
        }

        if ([SCIUtils getBoolPref:@"hide_ads"]) {
            // "New!" account id is 3538572169
            if ([obj isKindOfClass:%c(IGStoryTrayViewModel)] && (obj.isUnseenNux == YES || [obj.pk isEqualToString:@"3538572169"])) {
                NSLog(@"[SCInsta] Removing ads: story tray");

                shouldHide = YES;
            }
        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }
    }

    return [filteredObjs copy];
}
%end

// Modern IGDS app menus
%hook IGDSMenu
- (id)initWithMenuItems:(NSArray<IGDSMenuItem *> *)originalObjs edr:(BOOL)edr headerLabelText:(id)headerLabelText {
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        // Meta AI
        if (
            [[obj valueForKey:@"title"] isEqualToString:@"AI images"]
            || [[obj valueForKey:@"title"] isEqualToString:@"Meta AI"]
        ) {
            
            if ([SCIUtils getBoolPref:@"hide_meta_ai"]) {
                NSLog(@"[SCInsta] Hiding meta ai from IGDS menu");

                shouldHide = YES;
            }

        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }

    }

    return %orig([filteredObjs copy], edr, headerLabelText);
}
%end

/////////////////////////////////////////////////////////////////////////////

// Confirm buttons

/*
* Long press alerts can be triggered continuously by holding down on the button
*
* Instead, you call the "_didTap" method from the "_didLongPress" method
* Then, in the "_didTap" method, you make sure the confirm alert is only shown once
*/

static BOOL showingFeedItemUFIConfirm = NO;
static BOOL showingVerticalUFIConfirm = NO;

%hook IGFeedItemUFICell
- (void)UFIButtonBarDidTapOnLike:(id)arg1 {
    if ([SCIUtils getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) { %orig; }];
    }
    else {
        return %orig;
    }  
}

- (void)UFIButtonBarDidTapOnRepost:(id)arg1 {
    if (showingFeedItemUFIConfirm) return;

    if ([SCIUtils getBoolPref:@"repost_confirm"]) {
        NSLog(@"[SCInsta] Confirm repost triggered");

        showingFeedItemUFIConfirm = YES;

        [SCIUtils showConfirmation:^(void) { %orig; showingFeedItemUFIConfirm = NO; }
                     cancelHandler:^(void) { showingFeedItemUFIConfirm = NO; }];
    }
    else {
        return %orig;
    }
}

- (void)UFIButtonBarDidLongPressOnRepost:(id)arg1 {
    if ([SCIUtils getBoolPref:@"repost_confirm"]) {
        NSLog(@"[SCInsta] Confirm repost triggered (long press hack)");

        [self UFIButtonBarDidTapOnRepost:nil];
    }
    else {
        return %orig;
    }
}
- (void)UFIButtonBarDidLongPressOnRepost:(id)arg1 withGestureRecognizer:(id)arg2 {
    if ([SCIUtils getBoolPref:@"repost_confirm"]) {
        NSLog(@"[SCInsta] Confirm repost triggered (long press hack)");

        [self UFIButtonBarDidTapOnRepost:nil];
    }
    else {
        return %orig;
    }
}
%end

%hook IGSundialViewerVerticalUFI
- (void)_didTapLikeButton:(id)arg1 {
    if (showingVerticalUFIConfirm) return;

    if ([SCIUtils getBoolPref:@"like_confirm_reels"]) {
        NSLog(@"[SCInsta] Confirm reels like triggered");

        showingVerticalUFIConfirm = YES;

        [SCIUtils showConfirmation:^(void) { %orig; showingVerticalUFIConfirm = NO; }
                     cancelHandler:^(void) { showingVerticalUFIConfirm = NO; }];
    }
    else {
        return %orig;
    }
}

- (void)_didLongPressLikeButton:(id)arg1 {
    if ([SCIUtils getBoolPref:@"like_confirm_reels"]) {
        NSLog(@"[SCInsta] Confirm reels like triggered (long press hack)");

        [self _didTapLikeButton:nil];
    }
    else {
        return %orig;
    }
}

- (void)_didTapRepostButton:(id)arg1 {
    if (showingVerticalUFIConfirm) return;

    if ([SCIUtils getBoolPref:@"repost_confirm"]) {
        NSLog(@"[SCInsta] Confirm repost triggered");

        showingVerticalUFIConfirm = YES;

        [SCIUtils showConfirmation:^(void) { %orig; showingVerticalUFIConfirm = NO; }
                     cancelHandler:^(void) { showingVerticalUFIConfirm = NO; }];
    }
    else {
        return %orig;
    }
}

- (void)_didLongPressRepostButton:(id)arg1 {
    if ([SCIUtils getBoolPref:@"repost_confirm"]) {
        NSLog(@"[SCInsta] Confirm repost triggered (long press hack)");

        [self _didTapRepostButton:nil];
    }
    else {
        return %orig;
    }
}
%end

/////////////////////////////////////////////////////////////////////////////

// FLEX explorer gesture handler
%hook IGRootViewController
- (void)viewDidLoad {
    %orig;
    
    // Recognize 5-finger long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1;
    longPress.numberOfTouchesRequired = 5;
    [self.view addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    if ([SCIUtils getBoolPref:@"flex_instagram"]) {
        [[objc_getClass("FLEXManager") sharedManager] showExplorer];
    }
}
%end

// Disable safe mode (defaults reset upon subsequent crashes)
%hook IGSafeModeChecker
- (id)initWithInstacrashCounterProvider:(void *)provider crashThreshold:(unsigned long long)threshold {
    if ([SCIUtils getBoolPref:@"disable_safe_mode"]) return nil;

    return %orig(provider, threshold);
}
- (unsigned long long)crashCount {
    if ([SCIUtils getBoolPref:@"disable_safe_mode"]) {
        return 0;
    }

    return %orig;
}
%end
