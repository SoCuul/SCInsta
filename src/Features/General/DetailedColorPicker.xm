#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import "../../Utils.h"

%hook IGStoryEyedropperToggleButton
- (void)didMoveToWindow {
    %orig;

    if ([SCIManager getBoolPref:@"detailed_color_picker"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}

%new - (void)addLongPressGestureRecognizer {
    if ([self.gestureRecognizers count] == 0) {
        NSLog(@"[SCInsta] Adding color eyedroppper long press gesture recognizer");

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPress];
    }
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;
    
    UIColorPickerViewController *colorPickerController = [[UIColorPickerViewController alloc] init];

    colorPickerController.delegate = (id<UIColorPickerViewControllerDelegate>)self; // cast to suppress warnings
    colorPickerController.title = @"Text color";
    colorPickerController.modalPresentationStyle = UIModalPresentationPopover;
    colorPickerController.selectedColor = self.color;
    
    UIViewController *presentingVC = [SCIUtils nearestViewControllerForView:self];
    
    if (presentingVC != nil) {
        [presentingVC presentViewController:colorPickerController animated:YES completion:nil];
    }
}

// UIColorPickerViewControllerDelegate Protocol
%new - (void)colorPickerViewController:(UIColorPickerViewController *)viewController
                        didSelectColor:(UIColor *)color
                          continuously:(BOOL)continuously
{
    NSLog(@"[SCInsta] Selected text color: %@", color);

    self.color = color;

    [self setPushedDown:YES];

    // Trigger change for text color
    IGStoryTextEntryViewController *presentingVC = [SCIUtils nearestViewControllerForView:self];
    [presentingVC textViewControllerDidUpdateWithColor:color colorSource:0];
};
%end

%hook IGStoryColorPaletteView
- (CGFloat)collectionView:(id)view didSelectItemAtIndexPath:(id)index {
    UIView *colorPickingControls = [self superview];

    if ([colorPickingControls isKindOfClass:%c(IGStoryColorPickingControls)]) {
        IGStoryEyedropperToggleButton *_eyedropperToggleButton = MSHookIvar<IGStoryEyedropperToggleButton *>(colorPickingControls, "_eyedropperToggleButton");

        if (_eyedropperToggleButton != nil) {
            [_eyedropperToggleButton setPushedDown:NO];
        }
    }

    return %orig;
}
%end