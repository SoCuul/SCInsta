#import <substrate.h>
#import "InstagramHeaders.h"
#import "Tweak.h"
#import "Utils.h"
#import "Manager.h"
#import "Download.h"

#import "Controllers/SecurityViewController.h"
#import "Controllers/SettingsViewController.h"

///////////////////////////////////////////////////////////

// Direct story & screenshot handlers

#define VOID_HANDLESCREENSHOT(orig) [SCIManager getPref:@"remove_screenshot_alert"] ? nil : orig;
#define NONVOID_HANDLESCREENSHOT(orig) return VOID_HANDLESCREENSHOT(orig)

#define VOID_HANDLEREPLAY(orig) [SCIManager getPref:@"unlimited_replay"] ? nil : orig;
#define NONVOID_HANDLEREPLAY(orig) return VOID_HANDLEREPLAY(orig)

///////////////////////////////////////////////////////////

// * Tweak version *
NSString *SCIVersionString = @"v0.6.0";

// Variables that work across features
BOOL seenButtonEnabled = false;
BOOL dmVisualMsgsViewedButtonEnabled = false;

// Tweak first-time setup
%hook IGInstagramAppDelegate
- (_Bool)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)arg2 {
    %orig;

    NSLog(@"[SCInsta] First run, initializing");

    // Set default config values (if first-run key doesn't exist)
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SCInstaFirstRun"] == nil) {

        // Legacy (BHInsta) user migration
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BHInstaFirstRun"] != nil) {

            // Set new first-run key
            [[NSUserDefaults standardUserDefaults] setValue:@"SCInstaFirstRun" forKey:@"SCInstaFirstRun"];

            // Remove deprecated first-run key
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BHInstaFirstRun"];

        }

        else {
            NSLog(@"[SCInsta] Setting default values");

            [[NSUserDefaults standardUserDefaults] setValue:@"SCInstaFirstRun" forKey:@"SCInstaFirstRun"];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hide_ads"];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"dw_videos"];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"save_profile"];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"remove_screenshot_alert"];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"call_confirm"];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"no_suggested_chats"];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"no_suggested_threads"];

            // Display settings modal on screen
            NSLog(@"[SCInsta] Displaying SCInsta first-time settings modal");
            UIViewController *rootController = [[self window] rootViewController];
            SCISettingsViewController *settingsViewController = [SCISettingsViewController new];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
            
            [rootController presentViewController:navigationController animated:YES completion:nil];
        }

    }

    NSLog(@"[SCInsta] Cleaning cache...");
    [SCIManager cleanCache];

    return true;
}

// Biometric/passcode authentication
static BOOL isAuthenticationShowed = FALSE;

- (void)applicationDidBecomeActive:(id)arg1 {
    %orig;

    // Padlock (biometric auth)
    if ([SCIManager getPref:@"padlock"] && !isAuthenticationShowed) {
        UIViewController *rootController = [[self window] rootViewController];
        SCISecurityViewController *securityViewController = [SCISecurityViewController new];
        securityViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [rootController presentViewController:securityViewController animated:YES completion:nil];

        isAuthenticationShowed = TRUE;

        NSLog(@"[SCInsta] Padlock authentication: App enabled");
    }
}

- (void)applicationWillEnterForeground:(id)arg1 {
    %orig;

    // Reset padlock status
    isAuthenticationShowed = FALSE;
}
%end


// Instagram DM visual messages / IG stories
%hook IGDirectVisualMessageViewerSession
- (id)visualMessageViewerController:(id)arg1 didDetectScreenshotForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 { NONVOID_HANDLESCREENSHOT(%orig); }
- (id)visualMessageViewerController:(id)arg1 didEndPlaybackForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 forNavType:(NSInteger)arg4 { NONVOID_HANDLEREPLAY(%orig); }
%end

%hook IGDirectVisualMessageReplayService
- (id)visualMessageViewerController:(id)arg1 didDetectScreenshotForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 { NONVOID_HANDLESCREENSHOT(%orig); }
- (id)visualMessageViewerController:(id)arg1 didEndPlaybackForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 forNavType:(NSInteger)arg4 { NONVOID_HANDLEREPLAY(%orig); }
%end

%hook IGDirectVisualMessageReportService
- (id)visualMessageViewerController:(id)arg1 didDetectScreenshotForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 { NONVOID_HANDLESCREENSHOT(%orig); }
- (id)visualMessageViewerController:(id)arg1 didEndPlaybackForVisualMessage:(id)arg2 atIndex:(NSInteger)arg3 forNavType:(NSInteger)arg4 { NONVOID_HANDLEREPLAY(%orig); }
%end

%hook IGDirectVisualMessageViewerController
- (void)screenshotObserverDidSeeScreenshotTaken:(id)arg1 { VOID_HANDLESCREENSHOT(%orig); }
- (void)screenshotObserverDidSeeActiveScreenCapture:(id)arg1 event:(NSInteger)arg2 { VOID_HANDLESCREENSHOT(%orig); }
%end

// Instagram Screenshot Observer
%hook IGScreenshotObserver
- (id)initForController:(id)arg1 { NONVOID_HANDLESCREENSHOT(%orig); }
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

// Direct suggested chats (in search bar)
%hook IGDirectInboxSearchListAdapterDataSource
- (id)objectsForListAdapter:(id)arg1 {
    NSMutableArray *newObjs = [%orig mutableCopy];

    [newObjs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        // Section header 
        if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {

            // Broadcast channels
            if ([[obj labelTitle] isEqualToString:@"Suggested channels"]) {
                if ([SCIManager getPref:@"no_suggested_chats"]) {
                    NSLog(@"[SCInsta] Hiding suggested chats (header)");

                    [newObjs removeObjectAtIndex:idx];
                }
            }

            // Ask Meta AI
            else if ([[obj labelTitle] isEqualToString:@"Ask Meta AI"]) {
                if ([SCIManager getPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding meta ai suggested chats (header)");

                    [newObjs removeObjectAtIndex:idx];
                }
            }

            // AI
            else if ([[obj labelTitle] isEqualToString:@"AI"]) {
                if ([SCIManager getPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding ai suggested chats (header)");

                    [newObjs removeObjectAtIndex:idx];
                }
            }
            
        }

        // AI agents section
        else if (
            [obj isKindOfClass:%c(IGDirectInboxSearchAIAgentsPillsSectionViewModel)]
         || [obj isKindOfClass:%c(IGDirectInboxSearchAIAgentsSuggestedPromptLoggingViewModel)]
        ) {

            if ([SCIManager getPref:@"hide_meta_ai"]) {
                NSLog(@"[SCInsta] Hiding suggested chats (ai agents)");

                [newObjs removeObjectAtIndex:idx];
            }

        }

        // Recipients list
        else if ([obj isKindOfClass:%c(IGDirectRecipientCellViewModel)]) {

            // Broadcast channels
            if ([[obj recipient] isBroadcastChannel]) {
                if ([SCIManager getPref:@"no_suggested_chats"]) {
                    NSLog(@"[SCInsta] Hiding suggested chats (broadcast channels recipient)");

                    [newObjs removeObjectAtIndex:idx];
                }
            }
            
            // Meta AI (special section types)
            else if (([obj sectionType] == 20) || [obj sectionType] == 18) {
                if ([SCIManager getPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding meta ai suggested chats (meta ai recipient)");

                    [newObjs removeObjectAtIndex:idx];
                }
            }

            // Meta AI (catch-all)
            else if ([[[obj recipient] threadName] isEqualToString:@"Meta AI"]) {
                if ([SCIManager getPref:@"hide_meta_ai"]) {
                    NSLog(@"[SCInsta] Hiding meta ai suggested chats (meta ai recipient)");

                    [newObjs removeObjectAtIndex:idx];
                }
            }
        }

    }];

    return [newObjs copy];
}
%end

// Explore page results
%hook IGSearchListKitDataSource
- (id)objectsForListAdapter:(id)arg1 {
    NSMutableArray *newObjs = [%orig mutableCopy];

    [newObjs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // Meta AI
        if ([SCIManager getPref:@"hide_meta_ai"]) {

            // Section header 
            if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {

                // "Ask Meta AI" search results header
                if ([[obj labelTitle] isEqualToString:@"Ask Meta AI"]) {
                    [newObjs removeObjectAtIndex:idx];
                }

            }

            // Empty search bar upsell view
            else if ([obj isKindOfClass:%c(IGSearchNullStateUpsellViewModel)]) {
                [newObjs removeObjectAtIndex:idx];
            }

            // Meta AI search suggestions
            else if ([obj isKindOfClass:%c(IGSearchResultNestedGroupViewModel)]) {
                [newObjs removeObjectAtIndex:idx];
            }

            // Meta AI suggested search results
            else if ([obj isKindOfClass:%c(IGSearchResultViewModel)]) {

                // itemType 6 is meta ai suggestions
                if ([obj itemType] == 6) {
                    if ([SCIManager getPref:@"hide_meta_ai"]) {
                        [newObjs removeObjectAtIndex:idx];
                    }
                    
                }

                // Meta AI user account in search results
                else if ([[[obj title] string] isEqualToString:@"meta.ai"]) {
                    if ([SCIManager getPref:@"hide_meta_ai"]) {
                        [newObjs removeObjectAtIndex:idx];
                    }
                }

            }
            
        }

        // No suggested users
        if ([SCIManager getPref:@"no_suggested_users"]) {

            // Section header 
            if ([obj isKindOfClass:%c(IGLabelItemViewModel)]) {

                // "Suggested for you" search results header
                if ([[obj labelTitle] isEqualToString:@"Suggested for you"]) {
                    [newObjs removeObjectAtIndex:idx];
                }

            }

            // Instagram users
            else if ([obj isKindOfClass:%c(IGDiscoverPeopleItemConfiguration)]) {
                [newObjs removeObjectAtIndex:idx];
            }

            // See all suggested users
            else if ([obj isKindOfClass:%c(IGSeeAllItemConfiguration)]) {
                [newObjs removeObjectAtIndex:idx];
            }

        }

    }];

    return [newObjs copy];
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
        [[objc_getClass("FLEXManager") sharedManager] showExplorer];
    }
}
%end


/////////////////////////////////////////////////////////////////////////////

%hook HBForceCepheiPrefs
+ (BOOL)forceCepheiPrefsWhichIReallyNeedToAccessAndIKnowWhatImDoingISwear {
    return YES;
}
%end