#import <substrate.h>
#import "InstagramHeaders.h"
#import "Tweak.h"
#import "Utils.h"
#import "Manager.h"
#import "Settings/SCISettingsViewController.h"

#import "Controllers/SecurityViewController.h"

///////////////////////////////////////////////////////////

// Screenshot handlers

#define VOID_HANDLESCREENSHOT(orig) [SCIManager getBoolPref:@"remove_screenshot_alert"] ? nil : orig;
#define NONVOID_HANDLESCREENSHOT(orig) return VOID_HANDLESCREENSHOT(orig)

///////////////////////////////////////////////////////////

// * Tweak version *
NSString *SCIVersionString = @"v0.8.1";

// Variables that work across features
BOOL seenButtonEnabled = false;
BOOL dmVisualMsgsViewedButtonEnabled = false;

// Tweak first-time setup
%hook IGInstagramAppDelegate
- (_Bool)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)arg2 {
    %orig;

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
        @"dw_finger_duration": @(0.5)
    };
    [[NSUserDefaults standardUserDefaults] registerDefaults:sciDefaults];

    // Open settings for first-time users
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SCInstaFirstRun"] == nil) {
        NSLog(@"[SCInsta] First run, initializing");

        // Display settings modal on screen
        NSLog(@"[SCInsta] Displaying SCInsta first-time settings modal");
        UIViewController *rootController = [[self window] rootViewController];
        SCISettingsViewController *settingsViewController = [SCISettingsViewController new];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
        
        [rootController presentViewController:navigationController animated:YES completion:nil];

        // Done with first-time setup
        [[NSUserDefaults standardUserDefaults] setValue:@"SCInstaFirstRun" forKey:@"SCInstaFirstRun"];

    }

    NSLog(@"[SCInsta] Cleaning cache...");
    [SCIManager cleanCache];

    [self authPrompt];

    return true;
}

// Biometric/passcode authentication
BOOL isAuthenticationBeingShown = NO;

- (void)applicationDidEnterBackground:(id)arg1 {
    %orig;

    [self authPrompt];
}
- (void)applicationWillEnterForeground:(id)arg1 {
    %orig;

    [self authPrompt];
}
- (void)applicationDidBecomeActive:(id)arg1 {
    %orig;
    
    if ([SCIManager getBoolPref:@"flex_app_start"]) {
        [[objc_getClass("FLEXManager") sharedManager] showExplorer];
    }
}

%new - (void)authPrompt {
    // Padlock (biometric auth)
    if ([SCIManager getBoolPref:@"padlock"] && !isAuthenticationBeingShown) {
        UIViewController *rootController = [[self window] rootViewController];
        SCISecurityViewController *securityViewController = [SCISecurityViewController new];
        securityViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [rootController presentViewController:securityViewController animated:NO completion:nil];

        isAuthenticationBeingShown = YES;

        NSLog(@"[SCInsta] Padlock authentication: App enabled");
    }
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
    if ([SCIManager getBoolPref:@"remove_screenshot_alert"]) {
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
            if ([[obj uniqueIdentifier] isEqualToString:@"channels"]) {
                if ([SCIManager getBoolPref:@"no_suggested_chats"]) {
                    NSLog(@"[SCInsta] Hiding suggested chats (header)");

                    shouldHide = YES;
                }
            }

            // Ask Meta AI
            else if ([[obj labelTitle] isEqualToString:@"Ask Meta AI"]) {
                if ([SCIManager getBoolPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding meta ai suggested chats (header)");

                    shouldHide = YES;
                }
            }

            // AI
            else if ([[obj labelTitle] isEqualToString:@"AI"]) {
                if ([SCIManager getBoolPref:@"hide_meta_ai"]) {
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

            if ([SCIManager getBoolPref:@"hide_meta_ai"]) {
                NSLog(@"[SCInsta] Hiding suggested chats (ai agents)");

                shouldHide = YES;
            }

        }

        // Recipients list
        else if ([obj isKindOfClass:%c(IGDirectRecipientCellViewModel)]) {

            // Broadcast channels
            if ([[obj recipient] isBroadcastChannel]) {
                if ([SCIManager getBoolPref:@"no_suggested_chats"]) {
                    NSLog(@"[SCInsta] Hiding suggested chats (broadcast channels recipient)");

                    shouldHide = YES;
                }
            }
            
            // Meta AI (special section types)
            else if (([obj sectionType] == 20) || [obj sectionType] == 18) {
                if ([SCIManager getBoolPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding meta ai suggested chats (meta ai recipient)");

                    shouldHide = YES;
                }
            }

            // Meta AI (catch-all)
            else if ([[[obj recipient] threadName] isEqualToString:@"Meta AI"]) {
                if ([SCIManager getBoolPref:@"hide_meta_ai"]) {
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
        if ([SCIManager getBoolPref:@"hide_meta_ai"]) {
            
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
        if ([SCIManager getBoolPref:@"no_suggested_users"]) {
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
                if ([SCIManager getBoolPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding suggested chats (header: messages tab)");

                    shouldHide = YES;
                }
            }

            // "Accounts to follow/message" header
            else if ([[obj title] hasPrefix:@"Accounts to"]) {
                if ([SCIManager getBoolPref:@"no_suggested_users"]) {
                    NSLog(@"[SCInsta] Hiding suggested users: (header: inbox view)");

                    shouldHide = YES;
                }
            }

        }

        // Suggested recipients
        else if ([obj isKindOfClass:%c(IGDirectInboxSuggestedThreadCellViewModel)]) {
            if ([SCIManager getBoolPref:@"hide_meta_ai"]) {
                NSLog(@"[SCInsta] Hiding suggested chats (recipients: channels tab)");

                shouldHide = YES;
            }
        }

        // "Accounts to follow" recipients
        else if ([obj isKindOfClass:%c(IGDiscoverPeopleItemConfiguration)] || [obj isKindOfClass:%c(IGDiscoverPeopleConnectionItemConfiguration)]) {
            if ([SCIManager getBoolPref:@"no_suggested_users"]) {
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
        if ([SCIManager getBoolPref:@"hide_meta_ai"]) {

            // Section header 
            if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {

                // "Ask Meta AI" search results header
                if ([[obj labelTitle] isEqualToString:@"Ask Meta AI"]) {
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
                    if ([SCIManager getBoolPref:@"hide_meta_ai"]) {
                        shouldHide = YES;
                    }
                    
                }

                // Meta AI user account in search results
                else if ([[[obj title] string] isEqualToString:@"meta.ai"]) {
                    if ([SCIManager getBoolPref:@"hide_meta_ai"]) {
                        shouldHide = YES;
                    }
                }

            }
            
        }

        // No suggested users
        if ([SCIManager getBoolPref:@"no_suggested_users"]) {

            // Section header 
            if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {

                // "Suggested for you" search results header
                if ([[obj labelTitle] isEqualToString:@"Suggested for you"]) {
                    shouldHide = YES;
                }

            }

            // Instagram users
            else if ([obj isKindOfClass:%c(IGDiscoverPeopleItemConfiguration)]) {
                shouldHide = YES;
            }

            // See all suggested users
            else if ([obj isKindOfClass:%c(IGSeeAllItemConfiguration)]) {
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

/////////////////////////////////////////////////////////////////////////////

// Confirm buttons

static BOOL showingRepostConfirm = NO;

%hook IGFeedItemUFICell
- (void)UFIButtonBarDidTapOnLike:(id)arg1 {
    if ([SCIManager getBoolPref:@"like_confirm"]) {
        NSLog(@"[SCInsta] Confirm post like triggered");

        [SCIUtils showConfirmation:^(void) { %orig; }];
    }
    else {
        return %orig;
    }  
}

- (void)UFIButtonBarDidTapOnRepost:(id)arg1 {
    if ([SCIManager getBoolPref:@"repost_confirm"]) {
        NSLog(@"[SCInsta] Confirm post repost triggered");

        [SCIUtils showConfirmation:^(void) { %orig; }];
    }
    else {
        return %orig;
    }
}
%end

%hook IGSundialViewerVerticalUFI
- (void)_didTapRepostButton:(id)arg1 {
    if (showingRepostConfirm) return;

    if ([SCIManager getBoolPref:@"repost_confirm"]) {
        NSLog(@"[SCInsta] Confirm post repost triggered");

        showingRepostConfirm = YES;

        [SCIUtils showConfirmation:^(void) { %orig; showingRepostConfirm = NO; }
                     cancelHandler:^(void) { showingRepostConfirm = NO; }];
    }
    else {
        return %orig;
    }
}

// this gets called whenever you move your finger for some reason
// so instead pretend to click button as workaround
- (void)_didLongPressRepostButton:(id)arg1 {
    if ([SCIManager getBoolPref:@"repost_confirm"]) {
        NSLog(@"[SCInsta] Confirm post repost triggered (long press hack)");

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
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([SCIManager getBoolPref:@"flex_instagram"]) {
            [[objc_getClass("FLEXManager") sharedManager] showExplorer];
        }
    }
}
%end

// Disable safe mode (defaults reset upon subsequent crashes)
%hook IGSafeModeChecker
- (unsigned long long)crashCount {
    if ([SCIManager getBoolPref:@"disable_safe_mode"]) {
        return 0;
    }

    return %orig;
}
%end
