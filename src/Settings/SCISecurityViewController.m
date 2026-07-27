#import "SCISecurityViewController.h"

@implementation SCISecurityViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	blurView.frame = self.view.bounds;
	[self.view addSubview:blurView];
	
	UIButton *authenticateButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 200, 60)];
	[authenticateButton setTitle:@"Click to unlock app" forState:UIControlStateNormal];
	authenticateButton.center = self.view.center;
	[authenticateButton addTarget:self action:@selector(authenticateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:authenticateButton];
	
	[self authenticate];
}

- (void)authenticateButtonTapped:(id)sender {
	[self authenticate];
}

- (void)authenticate {
	LAContext *context = [[LAContext alloc] init];
	NSError *error = nil;

	NSLog(@"[SCInsta] Padlock authentication: Prompting for unlock");

	if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
		NSString *reason = @"Authenticate to unlock app";
		
		[context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:reason reply:^(BOOL success, NSError *authenticationError) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (success) {
					[self dismissViewControllerAnimated:YES completion:nil];

					NSLog(@"[SCInsta] Padlock authentication: Unlock success");
				} else {
					NSLog(@"[SCInsta] Padlock authentication: Unlock failed");
				}
			});
		}];
	} else {
		NSLog(@"[SCInsta] Padlock authentication: Device authentication not available");
	}
}

@end
