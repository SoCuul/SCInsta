#import "../../Manager.h"
#import "../../Utils.h"

%hook IGDirectNotesTrayRowCell
- (id)objectsForListAdapter:(id)arg1 {
    NSArray *originalObjs = %orig();
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    for (id obj in originalObjs) {
        BOOL shouldHide = NO;

        if ([SCIManager getPref:@"hide_friends_map"]) {

            if ([obj isKindOfClass:%c(IGDirectNotesTrayUserViewModel)]) {

                // Map cell type
                if ([[obj valueForKey:@"cellType"] isEqualToNumber:@5]) {
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