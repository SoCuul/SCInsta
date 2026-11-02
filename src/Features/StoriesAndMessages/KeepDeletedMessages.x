#import "../../Utils.h"
#import "../../InstagramHeaders.h"

// Modern Instagram versions
%hook IGDirectRealtimeIrisDeltaHandler
- (void)handleIrisDeltas:(NSArray<IGDirectRealtimeIrisDelta *> *)deltas {
    if (![SCIUtils getBoolPref:@"keep_deleted_message"]) {
        %orig(deltas);
        return;
    }

    NSArray *originalDeltas = deltas;
    NSMutableArray *filteredDeltas = [NSMutableArray arrayWithCapacity:[originalDeltas count]];

    for (IGDirectRealtimeIrisDelta *delta in originalDeltas) {
        if (![delta isKindOfClass:%c(IGDirectRealtimeIrisDelta)]) continue;

        // irisDeltaPayload
        IGDirectRealtimeIrisDeltaPayload *irisDeltaPayload = [delta valueForKey:@"payload"];
        if (![irisDeltaPayload isKindOfClass:%c(IGDirectRealtimeIrisDeltaPayload)]) continue;

        // threadDeltaPayload
        IGDirectRealtimeIrisThreadDeltaPayload *threadDeltaPayload = [irisDeltaPayload valueForKey:@"threadDeltaPayload"];
        if (![threadDeltaPayload isKindOfClass:%c(IGDirectRealtimeIrisThreadDeltaPayload)]) continue;

        // threadDelta
        IGDirectRealtimeIrisThreadDelta *threadDelta = [threadDeltaPayload valueForKey:@"threadDelta"];
        if (![threadDelta isKindOfClass:%c(IGDirectRealtimeIrisThreadDelta)]) continue;

        // removeItem_messageId
        NSString *removeItem_messageId = [threadDelta valueForKey:@"removeItem_messageId"];
        if (removeItem_messageId) continue;

        // * This general concept works for *replacing* the message contents instead of deleting it
        // * Not sure how to get the existing message content, to add it to the edit history though...
        // * It isn't very helpful to just replace the message contents, so this is still WIP
        /* NSString *messageId = [threadDelta valueForKey:@"removeItem_messageId"];
        if (messageId) {
            // SCILog(@"idk");
            IGDirectMessageContentMutation *mutation = [%c(IGDirectMessageContentMutation) new];
            [mutation setValue:@(3) forKey:@"subtype"];
            [mutation setValue:@"[deleted]" forKey:@"editText_newContent"];
            [mutation setValue:@(1) forKey:@"editText_editCount"]; // update to include old edit count + 1
            //[mutation setValue:@[] forKey:@"editText_editHistory"]; // update to include old edit history + current content

            // Modify thread delta to update message with new contents
            [threadDelta setValue:@(3) forKey:@"subtype"];
            [threadDelta setValue:messageId forKey:@"mutateItem_messageId"];
            [threadDelta setValue:mutation forKey:@"mutateItem_messageContentMutation"];
            [threadDelta setValue:nil forKey:@"removeItem_messageId"];
        }
        */

        [filteredDeltas addObject:delta];
    }

    %orig([filteredDeltas copy]);
}
%end

// Legacy versions fallback (just in case)
%hook IGDirectRealtimeIrisThreadDelta
+ (id)removeItemWithMessageId:(id)arg1 {
    if ([SCIUtils getBoolPref:@"keep_deleted_message"]) {
        arg1 = NULL;
    }

    return %orig(arg1);
}
%end

%hook IGDirectMessageUpdate
+ (id)removeMessageWithMessageId:(id)arg1 {
    if ([SCIUtils getBoolPref:@"keep_deleted_message"]) {
        arg1 = NULL;
    }
    
    return %orig(arg1);
}
%end