#import "../../Utils.h"
#import "../../InstagramHeaders.h"
#import "../../../modules/JGProgressHUD/JGProgressHUD.h"

%hook IGCoreTextView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIUtils getBoolPref:@"copy_description"]) {
        [self addHandleLongPress];
    }

    return;
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
}

%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    // Remove hashtags at end of string
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:@"\\s*(?:#[^\\s]+\\s*)+$"
                                              options:0
                                                error:nil];

    NSString *result = [[regex stringByReplacingMatchesInString:self.text
                                                        options:0
                                                          range:NSMakeRange(0, self.text.length)
                                                   withTemplate:@""]
          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSLog(@"[SCInsta] Copying description");

    // Copy text to system clipboard
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = result;

    // Notify user
    JGProgressHUD *HUD = [[JGProgressHUD alloc] init];
    HUD.textLabel.text = @"Copied text to clipboard";
    HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    
    [HUD showInView:topMostController().view];
    [HUD dismissAfterDelay:2.0];
}
%end