#import "../../InstagramHeaders.h"
#import "../../Manager.h"


%hook IGSundialViewerVideoCell
%property(nonatomic, assign) BOOL controlsHidden;

- (void)videoViewDidLoadVideo:(id)video {
	%orig;
	if ([SCIManager getPref:@"hide_controls"]) {
		self.controlsHidden = false;
		[self addControlsHiderButton];
	}
}

- (void)prepareForReuse {
	%orig;
	if ([SCIManager getPref:@"hide_controls"]) {
		self.controlsHidden = false;
		UIButton *hideButton = [self viewWithTag:123];
		if (hideButton) {
			[hideButton setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
		}
		[self.viewController animateCurrentVideoControllerVideoCellControlsOverlayVisible:YES];
	}
}

%new - (void)addControlsHiderButton {
    UIButton *ControlsHiderButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [ControlsHiderButton setTag:123];
    [ControlsHiderButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [ControlsHiderButton addTarget:self action:@selector(ControlsHiderButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    if (self.controlsHidden) {
        [ControlsHiderButton setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
    } else {
        [ControlsHiderButton setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
    }

    if (![self viewWithTag:123]) {
        [ControlsHiderButton setTintColor:[UIColor whiteColor]];
        [self addSubview:ControlsHiderButton];
			[NSLayoutConstraint activateConstraints:@[
              [ControlsHiderButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:70],
              [ControlsHiderButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
              [ControlsHiderButton.widthAnchor constraintEqualToConstant:30],
              [ControlsHiderButton.heightAnchor constraintEqualToConstant:30],
			]];
    }
}

%new - (void)ControlsHiderButtonHandler:(UIButton *)sender {
    IGSundialFeedViewController *rootVC = self.viewController;
	 if (self.controlsHidden) {
		 self.controlsHidden = false;
		 [rootVC animateCurrentVideoControllerVideoCellControlsOverlayVisible:YES];
		 [sender setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
	 } else {
		 self.controlsHidden = true;
		 [rootVC animateCurrentVideoControllerVideoCellControlsOverlayVisible:NO];
		 [sender setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
	 }
}


%end