#import "../../Utils.h"

static char targetStaticRef[] = "target";

%hook IGDirectNotesCreationView
- (id)initWithViewModel:(id)model
         featureSupport:(IGNotesCreationFeatureSupportModel *)support
  presentationAnimation:(id)animation
 composerUpdateListener:(id)listener
               delegate:(id)delegate
             layoutType:(long long)type
            userSession:(id)session
{
    if ([SCIUtils getBoolPref:@"enable_notes_customization"]) {

        // enableAnimatedEmojisInCreation
        @try {
            [support setValue:@(YES) forKey:@"enableAnimatedEmojisInCreation"];
        }
        @catch (NSException *exception) {
            NSLog(@"[SCInsta] WARNING: %@\n\nFull object: %@", exception.reason, support);
        }

        // enableBubbleCustomization
        @try {
            [support setValue:@(YES) forKey:@"enableBubbleCustomization"];
        }
        @catch (NSException *exception) {
            NSLog(@"[SCInsta] WARNING: %@\n\nFull object: %@", exception.reason, support);
        }

        // enableRandomThemeGenerator
        @try {
            [support setValue:@(YES) forKey:@"enableRandomThemeGenerator"];
        }
        @catch (NSException *exception) {
            NSLog(@"[SCInsta] WARNING: %@\n\nFull object: %@", exception.reason, support);
        }
        
    }

    return %orig(model, support, animation, listener, delegate, type, session);
}
%end

// Demangled name: IGDirectNotesUISwift.IGDirectNotesBubbleEditorColorPaletteView
%hook _TtC20IGDirectNotesUISwift41IGDirectNotesBubbleEditorColorPaletteView
%property (nonatomic, copy) UIColor *backgroundColor;
%property (nonatomic, copy) UIColor *textColor;
%property (nonatomic, copy) NSString *emojiText;

- (void)didMoveToWindow {
    %orig;

    if (![SCIUtils getBoolPref:@"custom_note_themes"]) return;
    
    // Inject buttons once in view lifecycle
    static char didInjectButtons;
    if (objc_getAssociatedObject(self, &didInjectButtons)) {
        return;
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.window) {
            return;
        }

        UIView *container = self.superview ?: self.window;
        if (!container) {
            return;
        }

        // Button config
        UIButtonConfiguration *config = [UIButtonConfiguration tintedButtonConfiguration];
        config.background.cornerRadius = 12.0;
        config.cornerStyle = UIButtonConfigurationCornerStyleFixed;
        config.contentInsets = NSDirectionalEdgeInsetsMake(13.7, 10, 13.7, 10);


        // Left button
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        leftButton.configuration = config;
        leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        leftButton.tintColor = [SCIUtils SCIColor_Primary];

        NSMutableAttributedString *attrTitleLeft = [[NSMutableAttributedString alloc] initWithString:@"Background"];
        [attrTitleLeft addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]
                          range:NSMakeRange(0, attrTitleLeft.length)
        ];
        [leftButton setAttributedTitle:attrTitleLeft forState:UIControlStateNormal];
        [leftButton sizeToFit];

        [leftButton addAction:[UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
            [self presentColorPicker:@"Background"];
        }] forControlEvents:UIControlEventTouchUpInside];

        // Middle button
        UIButton *middleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        middleButton.configuration = config;
        middleButton.translatesAutoresizingMaskIntoConstraints = NO;
        middleButton.tintColor = [SCIUtils SCIColor_Primary];

        NSMutableAttributedString *attrTitleMiddle = [[NSMutableAttributedString alloc] initWithString:@"Text"];
        [attrTitleMiddle addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]
                          range:NSMakeRange(0, attrTitleMiddle.length)
        ];
        [middleButton setAttributedTitle:attrTitleMiddle forState:UIControlStateNormal];
        [middleButton sizeToFit];

        [middleButton addAction:[UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
            [self presentColorPicker:@"Text"];
        }] forControlEvents:UIControlEventTouchUpInside];

        // Right button
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        rightButton.configuration = config;
        rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        rightButton.tintColor = [SCIUtils SCIColor_Primary];

        NSMutableAttributedString *attrTitleRight = [[NSMutableAttributedString alloc] initWithString:@"Emoji"];
        [attrTitleRight addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]
                          range:NSMakeRange(0, attrTitleRight.length)
        ];
        [rightButton setAttributedTitle:attrTitleRight forState:UIControlStateNormal];
        [rightButton sizeToFit];

        [rightButton addAction:[UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter Emoji Text"
                                                                           message:@"Click the Apply button after this to see the emoji"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Type emoji...";
            }];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                self.emojiText = alert.textFields[0].text;
                [self applySCICustomTheme:@"Emoji"];
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            
            UIViewController *vc = [SCIUtils nearestViewControllerForView:self];
            [vc presentViewController:alert animated:YES completion:nil];
        }] forControlEvents:UIControlEventTouchUpInside];


        // Create stack view
        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[leftButton, middleButton, rightButton]];
        stack.axis = UILayoutConstraintAxisHorizontal;
        stack.spacing = 15.0;
        stack.alignment = UIStackViewAlignmentCenter;
        stack.distribution = UIStackViewDistributionFillEqually;

        // Find max height among arranged subviews
        CGFloat maxHeight = 0.0;
        for (UIView *subview in stack.arrangedSubviews) {
            maxHeight = MAX(maxHeight, subview.bounds.size.height);
        }

        // Manual frame with side padding
        CGFloat bottomMargin = 15.0;
        
        CGRect viewFrame = [self convertRect:self.bounds toView:container];
        CGFloat y = CGRectGetMinY(viewFrame) - maxHeight - bottomMargin;
        CGFloat width = container.bounds.size.width - stack.spacing * 2;

        stack.frame = CGRectMake(stack.spacing, y, width, maxHeight);

        [stack layoutIfNeeded];
        [container addSubview:stack];

        objc_setAssociatedObject(
            self,
            &didInjectButtons,
            @YES,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    });
}

%new - (void)presentColorPicker:(NSString *)target {
    UIColorPickerViewController *colorPickerController = [[UIColorPickerViewController alloc] init];

    colorPickerController.delegate = (id<UIColorPickerViewControllerDelegate>)self; // cast to suppress warnings
    colorPickerController.title = [NSString stringWithFormat:@"%@ color", target];
    colorPickerController.modalPresentationStyle = UIModalPresentationPopover;
    colorPickerController.supportsAlpha = NO;

    // Show last picked color for type
    if ([target isEqualToString:@"Background"]) {
        colorPickerController.selectedColor = self.backgroundColor;
    }
    else if ([target isEqualToString:@"Text"]) {
        colorPickerController.selectedColor = self.textColor;
    }
    
    UIViewController *presentingVC = [SCIUtils nearestViewControllerForView:self];
    
    if (presentingVC != nil) {
        [presentingVC presentViewController:colorPickerController animated:YES completion:nil];
    }

    // Save which color target to update 
    objc_setAssociatedObject(
        presentingVC,
        &targetStaticRef,
        target,
        OBJC_ASSOCIATION_RETAIN_NONATOMIC
    );
}

// UIColorPickerViewControllerDelegate Protocol
%new - (void)colorPickerViewController:(UIColorPickerViewController *)viewController
                        didSelectColor:(UIColor *)color
                          continuously:(BOOL)continuously
{
    _TtC20IGDirectNotesUISwift41IGDirectNotesBubbleEditorColorPaletteView *bubbleEditorVC = [SCIUtils nearestViewControllerForView:self];
    
    NSString *target = objc_getAssociatedObject(bubbleEditorVC, &targetStaticRef);
    if (!target) return;
    
    // Update saved color target
    if ([target isEqualToString:@"Background"]) {
        self.backgroundColor = color;
    }
    else if ([target isEqualToString:@"Text"]) {
        self.textColor = color;
    }

    [self applySCICustomTheme:target];
};

%new - (void)applySCICustomTheme:(NSString *)target {
    // Get notes composer vc
    _TtC20IGDirectNotesUISwift39IGDirectNotesBubbleEditorViewController *parentVC = [SCIUtils nearestViewControllerForView:self];
    if (!parentVC) return;

    IGDirectNotesComposerViewController *composerVC = parentVC.delegate;
    if (!composerVC) return;

    // Get current theme model
    IGNotesCustomThemeCreationModel *model = [composerVC valueForKey:@"_selectedCustomThemeCreationModel"];
    if (!model) {
        // Create new note theme model
        model = [[%c(IGNotesCustomThemeCreationModel) alloc] init];
        if (!model) return;
    }

    SCILog(@"Current note theme model: %@", model);
    [model setValue:[composerVC valueForKey:@"_composerText"] forKey:@"customEmoji"];

    // Update saved color target
    if ([target isEqualToString:@"Background"]) {
        [model setValue:self.backgroundColor forKey:@"backgroundColor"];
    }
    else if ([target isEqualToString:@"Text"]) {
        [model setValue:self.textColor forKey:@"textColor"];
        [model setValue:self.textColor forKey:@"secondaryTextColor"];  
    }

    // Always set emoji to prevent it being overwritten
    [model setValue:self.emojiText forKey:@"customEmoji"];  

    SCILog(@"Updated note theme model: %@", model);

    // Apply custom notes theme
    [composerVC notesBubbleEditorViewControllerDidUpdateWithCustomThemeCreationModel:model];

    // Enable apply/cancel buttons
    UIView *parentVCView = [parentVC view];
    if (!parentVCView) return;

    NSArray<UIView *> *parentVCSubviews = [parentVCView subviews];
    if (!parentVCSubviews) return;

    [parentVCSubviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:%c(IGDSBottomButtonsView)]) {
            [obj setPrimaryButtonEnabled:YES];
            [obj setSecondaryButtonEnabled:YES];
        }
    }];
}
%end