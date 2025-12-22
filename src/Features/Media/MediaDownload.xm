#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import "../../Utils.h"
#import "../../Downloader/Download.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

static SCIDownloadDelegate *imageDownloadDelegate;
static SCIDownloadDelegate *videoDownloadDelegate;

static void initDownloaders () {
    // Init downloaders only once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageDownloadDelegate = [[SCIDownloadDelegate alloc] initWithAction:quickLook showProgress:NO];
        videoDownloadDelegate = [[SCIDownloadDelegate alloc] initWithAction:share showProgress:YES];
    });
}

/* * Feed * */

// Download feed images
%hook IGFeedPhotoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_feed_posts"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding feed photo download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    // Get photo instance
    IGPhoto *photo;

    if ([self.delegate isKindOfClass:%c(IGFeedItemPhotoCell)]) {
        IGFeedItemPhotoCellConfiguration *_configuration = MSHookIvar<IGFeedItemPhotoCellConfiguration *>(self.delegate, "_configuration");
        if (!_configuration) return;

        photo = MSHookIvar<IGPhoto *>(_configuration, "_photo");
    }
    else if ([self.delegate isKindOfClass:%c(IGFeedItemPagePhotoCell)]) {
        IGFeedItemPagePhotoCell *pagePhotoCell = self.delegate;

        photo = pagePhotoCell.pagePhotoPost.photo;
    }

    NSURL *photoUrl = [SCIUtils getPhotoUrl:photo];
    if (!photoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract photo url from post"];
        
        return;
    }

    // Download image & show in share menu
    initDownloaders();
    [imageDownloadDelegate downloadFileWithURL:photoUrl
                                 fileExtension:[[photoUrl lastPathComponent]pathExtension]
                                      hudLabel:nil];
}
%end

// Download feed videos
%hook IGModernFeedVideoCell.IGModernFeedVideoCell
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_feed_posts"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding feed video download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    NSURL *videoUrl = [SCIUtils getVideoUrlForMedia:[self mediaCellFeedItem]];
    if (!videoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract video url from post"];

        return;
    }

    // Download video & show in share menu
    initDownloaders();
    [videoDownloadDelegate downloadFileWithURL:videoUrl
                                 fileExtension:[[videoUrl lastPathComponent] pathExtension]
                                      hudLabel:nil];
}
%end


/* * Reels * */

// Download reels (photos)
%hook IGSundialViewerPhotoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_reels"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding reels photo download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    IGPhoto *_photo = MSHookIvar<IGPhoto *>(self, "_photo");

    NSURL *photoUrl = [SCIUtils getPhotoUrl:_photo];
    if (!photoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract photo url from reel"];

        return;
    }

    // Download image & show in share menu
    initDownloaders();
    [imageDownloadDelegate downloadFileWithURL:photoUrl
                                 fileExtension:[[photoUrl lastPathComponent]pathExtension]
                                      hudLabel:nil];
}
%end

// Download reels (videos)
%hook IGSundialViewerVideoCell
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_reels"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding reels video download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;
    
    NSLog(@"[SCInsta] Attempting to extract video URL from Reel...");
    
    // Try multiple approaches to get the video URL
    NSURL *videoUrl = nil;
    
    // Approach 1: Try to find AVPlayer in the view hierarchy
    videoUrl = [self findVideoURLInViewHierarchy:self];
    
    // Approach 2: If Approach 1 fails, try accessing via the old method
    if (!videoUrl && [self respondsToSelector:@selector(video)]) {
        videoUrl = [SCIUtils getVideoUrlForMedia:self.video];
    }
    
    if (!videoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not find video URL"];
        NSLog(@"[SCInsta] Failed to extract video URL from Reel");
        return;
    }
    
    NSLog(@"[SCInsta] Successfully extracted video URL: %@", videoUrl);

    // Download video & show in share menu
    initDownloaders();
    [videoDownloadDelegate downloadFileWithURL:videoUrl
                                 fileExtension:[[videoUrl lastPathComponent] pathExtension]
                                      hudLabel:nil];
}

%new - (NSURL *)findVideoURLInViewHierarchy:(UIView *)view {
    // Import AVFoundation classes at runtime
    Class AVPlayerClass = NSClassFromString(@"AVPlayer");
    Class AVPlayerLayerClass = NSClassFromString(@"AVPlayerLayer");
    Class AVURLAssetClass = NSClassFromString(@"AVURLAsset");
    
    if (!AVPlayerClass || !AVPlayerLayerClass || !AVURLAssetClass) {
        NSLog(@"[SCInsta] AVFoundation classes not available");
        return nil;
    }
    
    // Search for AVPlayerLayer in the layer hierarchy
    NSURL *url = [self searchLayerForVideoURL:view.layer];
    if (url) return url;
    
    // Search subviews recursively
    for (UIView *subview in view.subviews) {
        url = [self findVideoURLInViewHierarchy:subview];
        if (url) return url;
    }
    
    return nil;
}

%new - (NSURL *)searchLayerForVideoURL:(CALayer *)layer {
    Class AVPlayerLayerClass = NSClassFromString(@"AVPlayerLayer");
    Class AVURLAssetClass = NSClassFromString(@"AVURLAsset");
    
    // Check if this layer is an AVPlayerLayer
    if ([layer isKindOfClass:AVPlayerLayerClass]) {
        // Get the player from the layer
        id player = [layer valueForKey:@"player"];
        if (player) {
            // Get the current item
            id currentItem = [player valueForKey:@"currentItem"];
            if (currentItem) {
                // Get the asset
                id asset = [currentItem valueForKey:@"asset"];
                if ([asset isKindOfClass:AVURLAssetClass]) {
                    // Get the URL from the AVURLAsset
                    NSURL *url = [asset valueForKey:@"URL"];
                    if (url) {
                        NSLog(@"[SCInsta] Found video URL in AVPlayer: %@", url);
                        return url;
                    }
                }
            }
        }
    }
    
    // Search sublayers recursively
    for (CALayer *sublayer in layer.sublayers) {
        NSURL *url = [self searchLayerForVideoURL:sublayer];
        if (url) return url;
    }
    
    return nil;
}
%end


/* * Stories * */

// Download story (images)
%hook IGStoryPhotoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_story"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding story photo download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    NSURL *photoUrl = [SCIUtils getPhotoUrlForMedia:[self item]];
    if (!photoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract photo url from story"];
        
        return;
    }

    // Download image & show in share menu
    initDownloaders();
    [imageDownloadDelegate downloadFileWithURL:photoUrl
                                 fileExtension:[[photoUrl lastPathComponent]pathExtension]
                                      hudLabel:nil];
}
%end

// Download story (videos)
%hook IGStoryVideoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_story"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    //NSLog(@"[SCInsta] Adding story video download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    NSURL *videoUrl = nil;

    // Try the old methods first
    IGStoryFullscreenSectionController *captionDelegate = self.captionDelegate;
    if (captionDelegate) {
        videoUrl = [SCIUtils getVideoUrlForMedia:captionDelegate.currentStoryItem];
    }
    else {
        // Direct messages video player
        id parentVC = [SCIUtils nearestViewControllerForView:self];
        if (!parentVC || ![parentVC isKindOfClass:%c(IGDirectVisualMessageViewerController)]) return;

        IGDirectVisualMessageViewerViewModeAwareDataSource *_dataSource = MSHookIvar<IGDirectVisualMessageViewerViewModeAwareDataSource *>(parentVC, "_dataSource");
        if (!_dataSource) return;
        
        IGDirectVisualMessage *_currentMessage = MSHookIvar<IGDirectVisualMessage *>(_dataSource, "_currentMessage"); 
        if (!_currentMessage) return;
        
        IGVideo *rawVideo = _currentMessage.rawVideo;
        if (!rawVideo) return;
        
        videoUrl = [SCIUtils getVideoUrl:rawVideo];
    }
    
    // Fallback: try AVPlayer approach
    if (!videoUrl) {
        NSLog(@"[SCInsta] Story: Old methods failed, trying AVPlayer...");
        videoUrl = [self findVideoURLInViewHierarchy:self];
    }
    
    if (!videoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract video url from story"];
        NSLog(@"[SCInsta] Story: All methods failed");
        return;
    }

    NSLog(@"[SCInsta] Successfully extracted story video URL: %@", videoUrl);

    // Download video & show in share menu
    initDownloaders();
    [videoDownloadDelegate downloadFileWithURL:videoUrl
                                 fileExtension:[[videoUrl lastPathComponent] pathExtension]
                                      hudLabel:nil];
}

%new - (NSURL *)findVideoURLInViewHierarchy:(UIView *)view {
    Class AVPlayerClass = NSClassFromString(@"AVPlayer");
    Class AVPlayerLayerClass = NSClassFromString(@"AVPlayerLayer");
    Class AVURLAssetClass = NSClassFromString(@"AVURLAsset");
    
    if (!AVPlayerClass || !AVPlayerLayerClass || !AVURLAssetClass) {
        return nil;
    }
    
    NSURL *url = [self searchLayerForVideoURL:view.layer];
    if (url) return url;
    
    for (UIView *subview in view.subviews) {
        url = [self findVideoURLInViewHierarchy:subview];
        if (url) return url;
    }
    
    return nil;
}

%new - (NSURL *)searchLayerForVideoURL:(CALayer *)layer {
    Class AVPlayerLayerClass = NSClassFromString(@"AVPlayerLayer");
    Class AVURLAssetClass = NSClassFromString(@"AVURLAsset");
    
    if ([layer isKindOfClass:AVPlayerLayerClass]) {
        id player = [layer valueForKey:@"player"];
        if (player) {
            id currentItem = [player valueForKey:@"currentItem"];
            if (currentItem) {
                id asset = [currentItem valueForKey:@"asset"];
                if ([asset isKindOfClass:AVURLAssetClass]) {
                    NSURL *url = [asset valueForKey:@"URL"];
                    if (url) {
                        return url;
                    }
                }
            }
        }
    }
    
    for (CALayer *sublayer in layer.sublayers) {
        NSURL *url = [self searchLayerForVideoURL:sublayer];
        if (url) return url;
    }
    
    return nil;
}
%end


/* * Profile pictures * */

%hook IGProfilePictureImageView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"save_profile"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding profile picture long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    IGImageRequest *_imageRequest = MSHookIvar<IGImageRequest *>(self, "_imageRequest");
    if (!_imageRequest) return;
    
    NSURL *imageUrl = [_imageRequest url];
    if (!imageUrl) return;

    // Download image & preview in quick look
    initDownloaders();
    [imageDownloadDelegate downloadFileWithURL:imageUrl
                                 fileExtension:[[imageUrl lastPathComponent] pathExtension]
                                      hudLabel:@"Loading"];
}
%end