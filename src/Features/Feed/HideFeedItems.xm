#import "../../InstagramHeaders.h"
#import "../../Manager.h"

static NSArray *removeItemsInList(NSArray *list, BOOL isFeed) {
    NSArray *originalObjs = list;
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        // Remove suggested posts
        if (isFeed && [SCIManager getPref:@"no_suggested_post"]) {
            if (
                ([obj respondsToSelector:@selector(explorePostInFeed)] && [obj performSelector:@selector(explorePostInFeed)])
                || ([obj isKindOfClass:%c(IGFeedGroupHeaderViewModel)] && [[obj title] isEqualToString:@"Suggested Posts"])
            ) {
                NSLog(@"[SCInsta] Removing suggested posts");

                shouldHide = YES;

                continue;
            }
        }

        // Remove suggested reels (carousel)
        if (isFeed && [SCIManager getPref:@"no_suggested_reels"]) {
            if ([obj isKindOfClass:%c(IGFeedScrollableClipsModel)]) {
                NSLog(@"[SCInsta] Hiding suggested reels: reels carousel");

                shouldHide = YES;

                continue;
            }
        }
        
        // Remove suggested stories (carousel)
        if (isFeed && [SCIManager getPref:@"no_suggested_reels"]) {
            if ([obj isKindOfClass:%c(IGInFeedStoriesTrayModel)]) {
                NSLog(@"[SCInsta] Hiding suggested reels: stories carousel");

                shouldHide = YES;

                continue;
            }
        }
        
        // Remove suggested for you (accounts)
        if (isFeed && [SCIManager getPref:@"no_suggested_account"]) {
            if ([obj isKindOfClass:%c(IGHScrollAYMFModel)]) {
                NSLog(@"[SCInsta] Hiding suggested for you");

                shouldHide = YES;

                continue;
            }
        }

        // Remove suggested threads posts (carousel)
        if (isFeed && [SCIManager getPref:@"no_suggested_threads"]) {
            if ([obj isKindOfClass:%c(IGBloksFeedUnitModel)] || [obj isKindOfClass:objc_getClass("IGThreadsInFeedModels.IGThreadsInFeedModel")]) {
                NSLog(@"[SCInsta] Hiding threads posts");

                shouldHide = YES;

                continue;
            }
        }

        // Remove story tray
        if (isFeed && [SCIManager getPref:@"hide_stories_tray"]) {
            if ([obj isKindOfClass:%c(IGStoryDataController)]) {
                NSLog(@"[SCInsta] Hiding stories tray");

                shouldHide = YES;

                continue;
            }
        }

        // Hide entire feed
        if ([SCIManager getPref:@"hide_entire_feed"]) {
            if ([obj isKindOfClass:%c(IGPostCreationManager)] || [obj isKindOfClass:%c(IGMedia)] || [obj isKindOfClass:%c(IGEndOfFeedDemarcatorModel)] || [obj isKindOfClass:%c(IGSpinnerLabelViewModel)]) {
                NSLog(@"[SCInsta] Hiding entire feed");

                shouldHide = YES;

                continue;
            }
        }

        // Remove ads
        if ([SCIManager getPref:@"hide_ads"]) {
            if (([obj isKindOfClass:%c(IGFeedItem)] && ([obj isSponsored] || [obj isSponsoredApp])) || [obj isKindOfClass:%c(IGAdItem)]) {
                NSLog(@"[SCInsta] Removing ads");

                shouldHide = YES;

                continue;
            }
        }

        // Populate new objs array
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }
    }

    return [filteredObjs copy];
}

// Suggested posts
%hook IGMainFeedListAdapterDataSource
- (NSArray *)objectsForListAdapter:(id)arg1 {
    return removeItemsInList(%orig, YES);
}
%end
%hook IGContextualFeedViewController
- (NSArray *)objectsForListAdapter:(id)arg1 {
    if ([SCIManager getPref:@"hide_ads"]) {
        return removeItemsInList(%orig, NO);
    }

    return %orig;
}
%end
%hook IGVideoFeedViewController
- (NSArray *)objectsForListAdapter:(id)arg1 {
    if ([SCIManager getPref:@"hide_ads"]) {
        return removeItemsInList(%orig, NO);
    }

    return %orig;
}
%end
%hook IGChainingFeedViewController
- (NSArray *)objectsForListAdapter:(id)arg1 {
    if ([SCIManager getPref:@"hide_ads"]) {
        return removeItemsInList(%orig, NO);
    }

    return %orig;
}
%end
%hook IGStoryAdPool
- (id)initWithUserSession:(id)arg1 {
    if ([SCIManager getPref:@"hide_ads"]) {
        NSLog(@"[SCInsta] Removing ads");

        return nil;
    }

    return %orig;
}
%end
%hook IGStoryAdsManager
- (id)initWithUserSession:(id)arg1 storyViewerLoggingContext:(id)arg2 storyFullscreenSectionLoggingContext:(id)arg3 viewController:(id)arg4 {
    if ([SCIManager getPref:@"hide_ads"]) {
        NSLog(@"[SCInsta] Removing ads");

        return nil;
    }

    return %orig;
}
%end
%hook IGStoryAdsFetcher
- (id)initWithUserSession:(id)arg1 delegate:(id)arg2 {
    if ([SCIManager getPref:@"hide_ads"]) {
        NSLog(@"[SCInsta] Removing ads");

        return nil;
    }

    return %orig;
}
%end
// IG 148.0
%hook IGStoryAdsResponseParser
- (id)parsedObjectFromResponse:(id)arg1 {
    if ([SCIManager getPref:@"hide_ads"]) {
        NSLog(@"[SCInsta] Removing ads");

        return nil;
    }

    return %orig;
}
- (id)initWithReelStore:(id)arg1 {
    if ([SCIManager getPref:@"hide_ads"]) {
        NSLog(@"[SCInsta] Removing ads");

        return nil;
    }

    return %orig;
}
%end
%hook IGStoryAdsOptInTextView
- (id)initWithBrandedContentStyledString:(id)arg1 sponsoredPostLabel:(id)arg2 {
    if ([SCIManager getPref:@"hide_ads"]) {
        NSLog(@"[SCInsta] Removing ads");

        return nil;
    }

    return %orig;
}
%end
%hook IGSundialAdsResponseParser
- (id)parsedObjectFromResponse:(id)arg1 {
    if ([SCIManager getPref:@"hide_ads"]) {
        NSLog(@"[SCInsta] Removing ads");

        return nil;
    }

    return %orig;
}
- (id)initWithMediaStore:(id)arg1 userStore:(id)arg2 {
    if ([SCIManager getPref:@"hide_ads"]) {
        NSLog(@"[SCInsta] Removing ads");
        
        return nil;
    }
    
    return %orig;
}
%end

// Hide "suggested for you" text at end of feed
%hook IGEndOfFeedDemarcatorCellTopOfFeed
- (void)configureWithViewConfig:(id)arg1 {
    %orig;

    if ([SCIManager getPref:@"no_suggested_post"]) {
        NSLog(@"[SCInsta] Hiding end of feed message");

        // Hide suggested for you text
        UILabel *_titleLabel = MSHookIvar<UILabel *>(self, "_titleLabel");
        [_titleLabel setText:@""];
    }

    return;
}
%end