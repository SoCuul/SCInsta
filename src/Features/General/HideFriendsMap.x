#import "../../Utils.h"

%hook IGDirectNotesTrayRowCell
- (id)listAdapterObjects {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        if ([SCIUtils getBoolPref:@"hide_friends_map"]) {

            if ([obj isKindOfClass:%c(IGDirectNotesTrayUserViewModel)]) {

                if ([[obj valueForKey:@"notePk"] isEqualToString:@"friends_map"]) {
                    NSLog(@"[SCInsta] Hiding friends map");

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