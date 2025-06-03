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

// Meta AI direct search suggested topics header
%hook IGLabelItemViewModel
- (id)initWithLabelTitle:(id)arg1
                     tag:(NSInteger)arg2
        uniqueIdentifier:(id)arg3
           configuration:(id)arg4
     accessibilityTraits:(NSUInteger)arg5 {
    self = %orig;

    if ([[self labelTitle] isEqualToString:@"Ask Meta AI"]) {

        if ([SCIManager getPref:@"hide_meta_ai"]) {
            NSLog(@"[SCInsta] Hiding meta ai: explore suggested topics header");

            return nil;
        }

    }

    return self;
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

/////////////////////////////////////////////////////////////////////////////

// Explore

// Meta AI search bar ring button
%hook IGSearchBarDonutButton
- (void)didMoveToWindow {
    %orig;

    if ([SCIManager getPref:@"hide_meta_ai"]) {
        [self removeFromSuperview];
    }
}
%end

/* %hook IGGrowingTextView

%end */

%hook IGSearchBar
- (void)_setupTextView {
    %orig;

    IGGrowingTextView *_textView = MSHookIvar<IGGrowingTextView *>(self, "_textView");

    if ([SCIManager getPref:@"hide_meta_ai"]) {
        // Get rid of meta ai search text
        if ([[_textView placeholderText] containsString:@"Meta AI"]) {
            [_textView setPlaceholderText:@"Search"];
        }
    }
}
%end

%hook IGAnimatablePlaceholderTextFieldContainer
- (id)initWithConfig:(id)arg1 {
    NSLog(@"[SCInsta Test] %@", arg1);
    
    return %orig;
}
%end

/////////////////////////////////////////////////////////////////////////////

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