#import "../../Utils.h"

// Instagram TestFlight builds periodically present an "update available" nudge
// (IGCoreRootTestFlightNagPlugin.TestFlightUpdateNudgeViewController).
// Swallow every attempt to present it, including when wrapped in a navigation controller.

static BOOL SCIIsTestFlightNudge(UIViewController *vc) {
    if (!vc) return NO;

    UIViewController *target = vc;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        target = [(UINavigationController *)vc viewControllers].firstObject ?: vc;
    }

    NSString *className = NSStringFromClass([target class]);
    return [className containsString:@"TestFlightUpdateNudgeViewController"];
}

%hook UIViewController
- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion {
    if (SCIIsTestFlightNudge(vc)) {
        NSLog(@"[SCInsta] Blocked TestFlight update nudge: %@", vc);
        if (completion) completion();
        return;
    }

    %orig;
}
%end
