#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "../../modules/JGProgressHUD/JGProgressHUD.h"

#import "../InstagramHeaders.h"
#import "../Utils.h"

#import "Manager.h"

@interface SCIDownloadDelegate : NSObject <SCIDownloadDelegateProtocol>

typedef NS_ENUM(NSUInteger, DownloadAction) {
    share,
    quickLook
};
@property (nonatomic, readonly) DownloadAction action;
@property (nonatomic, readonly) BOOL showProgress;

@property (nonatomic, strong) SCIDownloadManager *downloadManager;
@property (nonatomic, strong) JGProgressHUD *hud;

- (instancetype)initWithAction:(DownloadAction)action showProgress:(BOOL)showProgress;

- (void)downloadFileWithURL:(NSURL *)url fileExtension:(NSString *)fileExtension hudLabel:(NSString *)hudLabel;

@end