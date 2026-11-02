#import "../../Utils.h"

%hook UIImpactFeedbackGenerator
- (void)impactOccurred {
    if (![SCIUtils getBoolPref:@"disable_haptics"]) %orig;
}
- (void)impactOccurredWithIntensity:(CGFloat)intensity {
    if (![SCIUtils getBoolPref:@"disable_haptics"]) %orig(intensity);
}
%end

%hook UINotificationFeedbackGenerator
- (void)notificationOccurred:(UINotificationFeedbackType)notificationType {
    if (![SCIUtils getBoolPref:@"disable_haptics"]) %orig(notificationType);
}
%end

%hook UISelectionFeedbackGenerator
- (void)selectionChanged {
    if (![SCIUtils getBoolPref:@"disable_haptics"]) %orig;
}
%end

%hook CHHapticEngine
- (BOOL)startAndReturnError:(NSError **)outError {
    if (![SCIUtils getBoolPref:@"disable_haptics"]) {
        return %orig(outError);
    }
    else {
        return NO;
    }
}
%end