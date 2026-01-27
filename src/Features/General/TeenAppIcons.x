#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import "../../Utils.h"

%hook IGImageWithAccessoryButton

- (void)didMoveToSuperview {
    %orig;

    [self addLongPressGestureRecognizer];
}

%new - (void)addLongPressGestureRecognizer {
    BOOL hasLongPress = [self.gestureRecognizers filteredArrayUsingPredicate:
        [NSPredicate predicateWithBlock:^BOOL(UIGestureRecognizer *gr, NSDictionary *_) {
            return [gr isKindOfClass:[UILongPressGestureRecognizer class]];
        }]
    ].count > 0;

    if (!hasLongPress) {
        NSLog(@"[SCInsta] Adding teen app icons long press gesture recognizer");

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPress];
    }
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateBegan && [SCIManager getBoolPref:@"teen_app_icons"]) {
        IGHomeFeedHeaderViewController *homeFeedHeaderVC = [SCIUtils nearestViewControllerForView:self];

        if (homeFeedHeaderVC != nil) {
            [homeFeedHeaderVC headerDidLongPressLogo:nil];
        }
    }
}

%end