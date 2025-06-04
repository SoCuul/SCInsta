#import "../../InstagramHeaders.h"
#import "../../Manager.h"

// Direct

// Meta AI button functionality on direct search bar
%hook IGDirectInboxViewController
- (void)searchBarMetaAIButtonTappedOnSearchBar:(id)arg1 {
    if ([SCIManager getPref:@"hide_meta_ai"])
{
        NSLog(@"[SCInsta] Hiding meta ai: direct search bar functionality");

        return;
    }
    
    return %orig;
}
%end

// AI agents in direct new message view
%hook IGDirectRecipientGenAIBotsResult
- (id)initWithGenAIBots:(id)arg1 lastFetchedTimestamp:(id)arg2 {
    if ([SCIManager getPref:@"hide_meta_ai"])
{
        NSLog(@"[SCInsta] Hiding meta ai: direct recipient ai agents");

        return nil;
    }
    
    return %orig;
}
%end

// Meta AI suggested user in direct new message view
%hook IGDirectThreadCreationViewController
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        if ([SCIManager getPref:@"hide_meta_ai"]) {
            
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

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }
    }

    return [filteredObjs copy];
}
%end

// Meta AI direct search suggested topics clouds
%hook IGDirectInboxSearchAIAgentsPillsContainerCell
- (void)didMoveToWindow {
    %orig;

    if ([SCIManager getPref:@"hide_meta_ai"]) {
        NSLog(@"[SCInsta] Hiding meta ai: direct search suggested topics clouds");

        [self removeFromSuperview];
    }
}
%end

// Meta AI direct search prompt suggestions in search results
%hook IGDirectInboxSearchAIAgentsSuggestedPromptRowCell
- (void)didMoveToWindow {
    %orig;

    if ([SCIManager getPref:@"hide_meta_ai"]) {
        NSLog(@"[SCInsta] Hiding meta ai: direct search ai prompt suggestions");

        [self removeFromSuperview];
    }
}
%end

// Meta AI in message composer
%hook IGDirectCommandSystemListViewController
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        if ([SCIManager getPref:@"hide_meta_ai"]) {

            if ([obj isKindOfClass:%c(IGDirectCommandSystemViewModel)]) {

                IGDirectCommandSystemViewModel *typedObj = (IGDirectCommandSystemViewModel *)obj;
                IGDirectCommandSystemRow *cmdSystemRow = (IGDirectCommandSystemRow *)[typedObj row];

                IGDirectCommandSystemResult *_commandResult_command = MSHookIvar<IGDirectCommandSystemResult *>(cmdSystemRow, "_commandResult_command");

                // Meta AI
                if ([[_commandResult_command title] isEqualToString:@"Meta AI"]) {
                    NSLog(@"[SCInsta] Hiding meta ai: direct message composer suggestion");

                    shouldHide = YES;
                }

                // Meta AI (Imagine)
                else if ([[_commandResult_command commandString] isEqualToString:@"/imagine"]) {
                    NSLog(@"[SCInsta] Hiding meta ai: direct message composer /imagine suggestion");

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

// Suggested AI chats in direct inbox header
%hook IGDirectInboxNavigationHeaderView
- (id)initWithFrame:(CGRect)arg1
              title:(id)arg2
          titleView:(id)arg3
  directInboxConfig:(IGDirectInboxConfig *)config
        userSession:(id)arg5
    loggingDelegate:(id)arg6
{
    if ([SCIManager getPref:@"hide_meta_ai"]) {
        NSLog(@"[SCInsta] Hiding meta ai: suggested ai chats in direct inbox header");

        @try {
            [config setValue:0 forKey:@"shouldShowAIChatsEntrypointButton"];
        }
        @catch (NSException *exception) {
            NSLog(@"[SCInsta] WARNING: %@\n\nFull object: %@", exception.reason, config);
        }
    }

    return %orig(arg1, arg2, arg3, [config copy], arg5, arg6);
}
%end
%end

/////////////////////////////////////////////////////////////////////////////

// Explore

// Meta AI explore search summary
%hook IGDiscoveryListKitDataSource
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        // Meta AI summary
        if ([obj isKindOfClass:%c(IGSearchMetaAIHCMModel)]) {
            
            if ([SCIManager getPref:@"hide_meta_ai"]) {
                NSLog(@"[SCInsta] Hiding explore meta ai search summary");

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

// Meta AI search bar ring button
%hook IGSearchBarDonutButton
- (void)didMoveToWindow {
    %orig;

    if ([SCIManager getPref:@"hide_meta_ai"]) {
        [self removeFromSuperview];
    }
}
%end

/////////////////////////////////////////////////////////////////////////////

// Reels/Sundial

// Suggested AI searches in comment section
%hook IGCommentThreadAICarousel
- (id)initWithLauncherSet:(id)arg1 {
    if ([SCIManager getPref:@"hide_meta_ai"]) {
        NSLog(@"[SCInsta] Hiding meta ai: suggested ai searches comment carousel");

        return nil;
    }

    return %orig;
}
%end

/////////////////////////////////////////////////////////////////////////////

// Other

// Meta AI-branded search bars
%hook IGSearchBar
- (id)initWithConfig:(IGSearchBarConfig *)arg1 {
    return %orig([self sanitizePlaceholderForConfig:arg1]);
}

- (id)initWithConfig:(IGSearchBarConfig *)arg1 userSession:(id)arg2 {
    return %orig([self sanitizePlaceholderForConfig:arg1], arg2);
}

- (void)setConfig:(IGSearchBarConfig *)arg1 {
    %orig([self sanitizePlaceholderForConfig:arg1]);

    return;
}

%new - (IGSearchBarConfig *)sanitizePlaceholderForConfig:(IGSearchBarConfig *)config {
    if ([SCIManager getPref:@"hide_meta_ai"]) {

        NSLog(@"[SCInsta] Hiding meta ai: reconfiguring search bar");

        NSString *placeholder = [config valueForKey:@"placeholder"];

        if ([placeholder containsString:@"Meta AI"]) {

            // placeholder
            @try {
                [config setValue:@"Search" forKey:@"placeholder"];
            }
            @catch (NSException *exception) {
                NSLog(@"[SCInsta] WARNING: %@\n\nFull object: %@", exception.reason, config);
            }

            // shouldAnimatePlaceholder
            @try {
                [config setValue:0 forKey:@"shouldAnimatePlaceholder"];
            }
            @catch (NSException *exception) {
                NSLog(@"[SCInsta] WARNING: %@\n\nFull object: %@", exception.reason, config);
            }

            NSLog(@"[SCInsta] Changed search bar placeholder from: \"%@\" to \"%@\"", placeholder, [config valueForKey:@"placeholder"]);

            // leftIconStyle
            @try {
                [config setValue:0 forKey:@"leftIconStyle"];
            }
            @catch (NSException *exception) {
                NSLog(@"[SCInsta] WARNING: %@\n\nFull object: %@", exception.reason, config);
            }

            // rightButtonStyle
            @try {
                [config setValue:0 forKey:@"rightButtonStyle"];
            }
            @catch (NSException *exception) {
                NSLog(@"[SCInsta] WARNING: %@\n\nFull object: %@", exception.reason, config);
            }
        }

    }

    return [config copy];
}
%end

// Themed in-app buttons
%hook IGTapButton
- (void)didMoveToWindow {
    %orig;

    if ([SCIManager getPref:@"hide_meta_ai"]) {

        // Hide buttons that are associated with meta ai
        if ([self.accessibilityIdentifier containsString:@"meta_ai"]) {
            NSLog(@"[SCInsta] Hiding meta ai: meta ai associated button");

            [self removeFromSuperview];
        }

    }
}
%end