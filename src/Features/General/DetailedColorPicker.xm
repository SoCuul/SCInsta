#import "../../InstagramHeaders.h"

%hook IGStoryEyedropperToggleButton
- (void)didMoveToWindow {
    %orig;

    if ([SCIManager getPref:@"detailed_color_picker"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}

%new - (UIViewController *)parentViewController {
    UIResponder *responder = [self nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

%new - (void)addLongPressGestureRecognizer {
    if ([self.gestureRecognizers count] == 0) {
        NSLog(@"[SCInsta] Adding color eyedroppper long press gesture recognizer");

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress)];
        [self addGestureRecognizer:longPress];
    }
}
%new - (void)handleLongPress {
    UIColorPickerViewController *colorPickerController = [[UIColorPickerViewController alloc] init];

    colorPickerController.delegate = (id<UIColorPickerViewControllerDelegate>)self; // cast to suppress warnings
    colorPickerController.title = @"Text color";
    colorPickerController.modalPresentationStyle = UIModalPresentationPopover;
    colorPickerController.selectedColor = self.color;
    
    UIViewController *presentingVC = [self parentViewController];
    
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

    [self setSelected:YES animated:YES];

    // Trigger change for text color
    IGStoryTextEntryViewController *presentingVC = [self parentViewController];
    [presentingVC textViewControllerDidUpdateWithColor:color];
};
%end

%hook IGStoryColorPaletteView
- (CGFloat)collectionView:(id)view didSelectItemAtIndexPath:(id)index {
    UIView *colorPickingControls = [self superview];

    if ([colorPickingControls isKindOfClass:%c(IGStoryColorPickingControls)]) {
        IGStoryEyedropperToggleButton *_eyedropperToggleButton = MSHookIvar<IGStoryEyedropperToggleButton *>(colorPickingControls, "_eyedropperToggleButton");

        if (_eyedropperToggleButton != nil) {
            [_eyedropperToggleButton setSelected:NO animated:YES];
        }
    }

    return %orig;
}
%end