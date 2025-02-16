#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Manager.h"
#import "Download.h"
#import "Controllers/SettingsViewController.h"
#import "Controllers/SecurityViewController.h"
#import "../modules/JGProgressHUD/JGProgressHUD.h"

@interface IGRootViewController : UIViewController
- (void)addHandleLongPress; // new
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender; // new
@end

@interface IGViewController : UIViewController
- (void)_superPresentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(id)completion;
@end

@interface IGMainFeedAppHeaderController : UIViewController
- (void)_superPresentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(id)completion; // new
@end

@interface IGShimmeringGridView : UIView
@end

@interface IGExploreGridViewController : IGViewController
@end

@interface UIImage ()
- (NSString *)ig_imageName;
@end

@interface IGProfileMenuSheetViewController :  IGViewController
@end

@interface IGTabBar: UIView
@end

@interface IGTableViewCell: UITableViewCell
- (id)initWithReuseIdentifier:(NSString *)identifier;
@end

@interface IGProfileSheetTableViewCell : IGTableViewCell
@end

@interface IGTallNavigationBarView : UIView
@end

@interface UIView (RCTViewUnmounting)
@property(retain, nonatomic) UIViewController *viewController;
- (UIView *)_rootView;
@end

@interface IGImageSpecifier : NSObject
@property(readonly, nonatomic) NSURL *url;
@end

@interface IGVideo : NSObject
@property(readonly, nonatomic) NSSet *allVideoURLs;
@end

@interface IGMedia : NSObject
@property(readonly) IGVideo *video;
@property long long likeCount;
@end

@interface IGPhoto: NSObject
@end

@interface IGPostItem : NSObject
@property(readonly) IGVideo *video;
@property(readonly) IGPhoto *photo;
@end

@interface IGPageMediaView : UIView
@property(readonly) NSMutableArray <IGPostItem *> *items;
- (IGPostItem *)currentMediaItem;
@end

@interface IGFeedItem : NSObject
@property long long likeCount;
@property(readonly) IGVideo *video;
- (BOOL)isSponsored;
- (BOOL)isSponsoredApp;
@end

@interface IGImageView : UIImageView
@property(retain, nonatomic) IGImageSpecifier *imageSpecifier;
@end

@interface IGFeedItemPagePhotoCell : UICollectionViewCell
@property (nonatomic, strong) id post;
@property (nonatomic, strong) IGPostItem *pagePhotoPost;
@end

@interface IGProfilePicturePreviewViewController : UIViewController
{
    IGImageView *_profilePictureView;
}
@property (nonatomic, strong) JGProgressHUD *hud;
- (void)addHandleLongPress; // new
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender; // new
@end

@interface IGProfilePicturePreviewViewController () <SCIDownloadDelegate>
@end

@interface IGFeedItemMediaCell : UICollectionViewCell
@property(retain, nonatomic) IGMedia *post;
- (UIImage *)mediaCellCurrentlyDisplayedImage;
@end

@interface IGFeedItemPhotoCell : IGFeedItemMediaCell
@end

@interface IGFeedItemPhotoCellConfiguration : NSObject
@end

@interface IGFeedPhotoView : UIView
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) JGProgressHUD *hud;
@end
@interface IGFeedPhotoView () <SCIDownloadDelegate>
@end

@interface IGSundialFeedViewController : UIViewController
- (void)animateCurrentVideoControllerVideoCellControlsOverlayVisible:(BOOL)a;
@end

@interface IGSundialViewerVideoCell : UICollectionViewCell
- (void)addHandleLongPress; // new
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender; // new
- (void)addControlsHiderButton; // new
- (void)ControlsHiderButtonHandler:(UIButton *)sender; // new
@property (nonatomic, strong) JGProgressHUD *hud; 
@property(readonly, nonatomic) IGMedia *video;
@property (nonatomic, assign, readonly) IGSundialFeedViewController *viewController; // new property
@property(nonatomic, assign) BOOL controlsHidden; // new property
@end

@interface IGSundialViewerVideoCell () <SCIDownloadDelegate>
@end

@interface IGModernFeedVideoCell : IGFeedItemMediaCell
- (void)addHandleLongPress; // new
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender; // new
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, strong) id delegate;
@end

@interface IGModernFeedVideoCell () <SCIDownloadDelegate>
@end

@interface IGVideoPlayer : NSObject {
  IGVideo *_video;
}
@end


/**
 * For download story photo/video
 */
@protocol IGStoryPlayerMediaViewType
@end

@interface IGImageProgressView : UIView
@property(retain, nonatomic) IGImageSpecifier *imageSpecifier;
@end

@interface IGStoryPhotoView : UIView<IGStoryPlayerMediaViewType>
@property(retain, nonatomic) IGImageSpecifier *mediaViewLastLoadedImageSpecifier;
@property(readonly, nonatomic) IGImageProgressView *photoView;
@end

@interface IGStoryVideoView : UIView<IGStoryPlayerMediaViewType>
@end

@interface IGStoryFullscreenDefaultFooterView : UIView
@end

@interface IGStoryFullscreenFooterContainerView : UIView
@property(nonatomic) IGStoryFullscreenDefaultFooterView *defaultFooterView;
@end

@interface IGStoryFullscreenOverlayView : UIView
@property(retain, nonatomic) IGStoryFullscreenFooterContainerView *footerContainerView;
@end

@interface IGStoryFullscreenCell : UICollectionViewCell
@end

@interface IGStoryViewerViewController : UIViewController
{
    id _focusStoryItemOnEntry;
}
- (id)_getMostVisibleSectionController;
- (void)fullscreenSectionController:(id)arg1 didMarkItemAsSeen:(id)arg2;
@property (nonatomic) UIView *contentViewForSnapshot;
@end

@interface IGStoryFullscreenSectionController : NSObject
@property (nonatomic) id delegate;
@end

@interface IGStoryViewerContainerView : UIView
@property (retain, nonatomic) UIView<IGStoryPlayerMediaViewType> *mediaView;
@property (nonatomic) IGStoryFullscreenOverlayView *overlayView;
@property (nonatomic, weak) id delegate;
@property (nonatomic, retain) UIButton *hDownloadButton; // new property
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, retain) NSString *fileextension;
- (void)hDownloadButtonPressed:(UIButton *)sender;
@end

@interface IGStoryViewerContainerView () <SCIDownloadDelegate>
@end


/**
 * For HD profile picture
 */
@interface IGUser : NSObject
@property NSInteger followStatus;
@property(copy) NSString *username;
@property BOOL followsCurrentUser;
- (NSURL *)HDProfilePicURL;
- (BOOL)isUser;
@end

@interface IGFollowController : NSObject 
@property IGUser *user;
@end

@interface IGCoreTextView : UIView
@property(nonatomic, strong) NSString *text;
- (void)addHandleLongPress; // new
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender; // new
@end

/**
 * Determine If User Is Following You
 */
@interface IGProfileBioModel
@property (readonly, copy, nonatomic) IGUser *user;
@end

@interface IGProfileViewController : UIViewController {
    IGProfileBioModel *_bioModel;
}
@end

@interface IGProfileSimpleAvatarStatsCell : UICollectionViewCell
@property (nonatomic, retain) UIView *isFollowingYouBadge; // new property
@property (nonatomic, retain) UILabel *isFollowingYouLabel; // new property
- (void)addIsFollowingYouBadgeView; // new
@end

@interface IGUserSession : NSObject
@property (readonly, nonatomic) IGUser *user;
@end

@interface IGWindow : UIWindow
@property (nonatomic) __weak IGUserSession *userSession;
@end

@interface IGShakeWindow : UIWindow
@property (nonatomic) __weak IGUserSession *userSession;
@end

@interface IGStyledString : NSObject
@property (retain, nonatomic) NSMutableAttributedString *attributedString;
- (void)appendString:(id)arg1;
@end

@interface IGInstagramAppDelegate : NSObject <UIApplicationDelegate>
@end

@interface IGDirectInboxSearchAIAgentsPillsContainerCell : UIView
@end

@interface IGTapButton : UIButton
@end

@interface IGLabel : UILabel
@end

@interface IGLabelItemViewModel : NSObject
- (id)labelTitle;
@end

@interface IGDirectInboxSuggestedThreadCellViewModel : NSObject
@end

@interface IGDirectInboxHeaderCellViewModel : NSObject
- (id)title;
@end

@interface IGSearchResultViewModel : NSObject
- (id)title;
- (NSUInteger)itemType;
@end

@interface IGDirectShareRecipient : NSObject
- (NSString *)threadName;
- (BOOL)isBroadcastChannel;
@end

@interface IGDirectRecipientCellViewModel : NSObject
- (id)recipient;
- (NSInteger)sectionType;
@end

@interface IGDirectInboxSearchAIAgentsSuggestedPromptRowCell : UIView
@end

@interface IGDSSegmentedPillBarView : UIView
- (id)delegate;
@end

@interface IGImageWithAccessoryButton : IGTapButton
@end

@interface IGSearchBarDonutButton : UIView
@end

@interface IGAnimatablePlaceholderTextField : UITextField
@end

@interface IGDirectCommandSystemViewModel : NSObject
- (id)row;
@end

@interface IGDirectCommandSystemRow : NSObject
@end

@interface IGDirectCommandSystemResult : NSObject
- (id)title;
- (id)commandString;
@end

@interface IGGrowingTextView : UIView
- (id)placeholderText;
- (void)setPlaceholderText:(id)arg1;
@end

@interface IGUnifiedVideoCollectionView : UIScrollView
@end

@interface IGMainAppSurfaceIntent:NSObject
@end


/////////////////////////////////////////////////////////////////////////////



static BOOL is_iPad() {
    if ([(NSString *)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        return YES;
    }
    return NO;
}



/////////////////////////////////////////////////////////////////////////////



static UIViewController * _Nullable _topMostController(UIViewController * _Nonnull cont) {
    UIViewController *topController = cont;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    if ([topController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)topController).visibleViewController;
        if (visible) {
            topController = visible;
        }
    }
    return (topController != cont ? topController : nil);
}
static UIViewController * _Nonnull topMostController() {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *next = nil;
    while ((next = _topMostController(topController)) != nil) {
        topController = next;
    }
    return topController;
}

@class FLEXAlert, FLEXAlertAction;

typedef void (^FLEXAlertReveal)(void);
typedef void (^FLEXAlertBuilder)(FLEXAlert *make);
typedef FLEXAlert * _Nonnull (^FLEXAlertStringProperty)(NSString * _Nullable);
typedef FLEXAlert * _Nonnull (^FLEXAlertStringArg)(NSString * _Nullable);
typedef FLEXAlert * _Nonnull (^FLEXAlertTextField)(void(^configurationHandler)(UITextField *textField));
typedef FLEXAlertAction * _Nonnull (^FLEXAlertAddAction)(NSString *title);
typedef FLEXAlertAction * _Nonnull (^FLEXAlertActionStringProperty)(NSString * _Nullable);
typedef FLEXAlertAction * _Nonnull (^FLEXAlertActionProperty)(void);
typedef FLEXAlertAction * _Nonnull (^FLEXAlertActionBOOLProperty)(BOOL);
typedef FLEXAlertAction * _Nonnull (^FLEXAlertActionHandler)(void(^handler)(NSArray<NSString *> *strings));

@interface FLEXAlert : NSObject

// Shows a simple alert with one button which says "Dismiss"
+ (void)showAlert:(NSString * _Nullable)title message:(NSString * _Nullable)message from:(UIViewController *)viewController;

// Shows a simple alert with no buttons and only a title, for half a second
+ (void)showQuickAlert:(NSString *)title from:(UIViewController *)viewController;

// Construct and display an alert
+ (void)makeAlert:(FLEXAlertBuilder)block showFrom:(UIViewController *)viewController;
// Construct and display an action sheet-style alert
+ (void)makeSheet:(FLEXAlertBuilder)block
         showFrom:(UIViewController *)viewController
           source:(id)viewOrBarItem;

// Construct an alert
+ (UIAlertController *)makeAlert:(FLEXAlertBuilder)block;
// Construct an action sheet-style alert
+ (UIAlertController *)makeSheet:(FLEXAlertBuilder)block;

// Set the alert's title.
///
// Call in succession to append strings to the title.
@property (nonatomic, readonly) FLEXAlertStringProperty title;
// Set the alert's message.
///
// Call in succession to append strings to the message.
@property (nonatomic, readonly) FLEXAlertStringProperty message;
// Add a button with a given title with the default style and no action.
@property (nonatomic, readonly) FLEXAlertAddAction button;
// Add a text field with the given (optional) placeholder text.
@property (nonatomic, readonly) FLEXAlertStringArg textField;
// Add and configure the given text field.
///
// Use this if you need to more than set the placeholder, such as
// supply a delegate, make it secure entry, or change other attributes.
@property (nonatomic, readonly) FLEXAlertTextField configuredTextField;

@end

@interface FLEXAlertAction : NSObject

// Set the action's title.
///
// Call in succession to append strings to the title.
@property (nonatomic, readonly) FLEXAlertActionStringProperty title;
// Make the action destructive. It appears with red text.
@property (nonatomic, readonly) FLEXAlertActionProperty destructiveStyle;
// Make the action cancel-style. It appears with a bolder font.
@property (nonatomic, readonly) FLEXAlertActionProperty cancelStyle;
// Enable or disable the action. Enabled by default.
@property (nonatomic, readonly) FLEXAlertActionBOOLProperty enabled;
// Give the button an action. The action takes an array of text field strings.
@property (nonatomic, readonly) FLEXAlertActionHandler handler;
// Access the underlying UIAlertAction, should you need to change it while
// the encompassing alert is being displayed. For example, you may want to
// enable or disable a button based on the input of some text fields in the alert.
// Do not call this more than once per instance.
@property (nonatomic, readonly) UIAlertAction *action;

@end
@interface FLEXManager : NSObject
+ (instancetype)sharedManager;
- (void)showExplorer;
- (void)hideExplorer;
- (void)toggleExplorer;
@end
