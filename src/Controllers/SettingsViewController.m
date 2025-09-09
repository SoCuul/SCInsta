#import "SettingsViewController.h"

@interface SCISettingsViewController ()
@property (nonatomic, assign) BOOL hasDynamicSpecifiers;
@property (nonatomic, retain) NSMutableDictionary *dynamicSpecifiers;
@end

@implementation SCISettingsViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"SCInsta Settings";
        [self.navigationController.navigationBar setPrefersLargeTitles:false];
    }
    return self;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleInsetGrouped;
}

// Pref Section
- (PSSpecifier *)newSectionWithTitle:(NSString *)header footer:(NSString *)footer {
    PSSpecifier *section = [PSSpecifier preferenceSpecifierNamed:header target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    if (footer != nil) {
        [section setProperty:footer forKey:@"footerText"];
    }
    return section;
}

// Pref Switch Cell
- (PSSpecifier *)newSwitchCellWithTitle:(NSString *)titleText detailTitle:(NSString *)detailText key:(NSString *)keyText changeAction:(SEL)changeAction {
    PSSpecifier *switchCell = [PSSpecifier preferenceSpecifierNamed:titleText target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
    
    [switchCell setProperty:keyText forKey:@"key"];
    [switchCell setProperty:keyText forKey:@"id"];
    [switchCell setProperty:@YES forKey:@"big"];
    [switchCell setProperty:SCISwitchTableCell.class forKey:@"cellClass"];
    [switchCell setProperty:NSBundle.mainBundle.bundleIdentifier forKey:@"defaults"];
    //[switchCell setProperty:@([SCIManager getBoolPref:keyText]) forKey:@"default"];
    [switchCell setProperty:NSStringFromSelector(changeAction) forKey:@"switchAction"];
    if (detailText != nil) {
        [switchCell setProperty:detailText forKey:@"subtitle"];
    }
    return switchCell;
}

// Pref Stepper Cell
- (PSSpecifier *)newStepperCellWithTitle:(NSString *)titleText key:(NSString *)keyText min:(double)min max:(double)max step:(double)step label:(NSString *)label singularLabel:(NSString *)singularLabel {
    PSSpecifier *stepperCell = [PSSpecifier preferenceSpecifierNamed:titleText target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSTitleValueCell edit:nil];
    
    [stepperCell setProperty:keyText forKey:@"key"];
    [stepperCell setProperty:keyText forKey:@"id"];
    [stepperCell setProperty:@YES forKey:@"big"];
    [stepperCell setProperty:SCIStepperTableCell.class forKey:@"cellClass"];
    [stepperCell setProperty:NSBundle.mainBundle.bundleIdentifier forKey:@"defaults"];

    [stepperCell setProperty:@(min) forKey:@"min"];
    [stepperCell setProperty:@(max) forKey:@"max"];
    [stepperCell setProperty:@(step) forKey:@"step"];
    [stepperCell setProperty:label forKey:@"label"];
    [stepperCell setProperty:singularLabel forKey:@"singularLabel"];

    return stepperCell;
}

// Pref Link Cell
- (PSSpecifier *)newLinkCellWithTitle:(NSString *)titleText detailTitle:(NSString *)detailText url:(NSString *)url iconURL:(NSString *)iconURL iconTransparentBG:(BOOL)iconTransparentBG {
    PSSpecifier *LinkCell = [PSSpecifier preferenceSpecifierNamed:titleText target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSButtonCell edit:nil];
    
    [LinkCell setButtonAction:@selector(hb_openURL:)];
    [LinkCell setProperty:HBLinkTableCell.class forKey:@"cellClass"];
    [LinkCell setProperty:url forKey:@"url"];
    if (detailText != nil) {
        [LinkCell setProperty:detailText forKey:@"subtitle"];
    }
    if (iconURL != nil) {
        [LinkCell setProperty:iconURL forKey:@"iconURL"];
        [LinkCell setProperty:@YES forKey:@"iconCircular"];
        [LinkCell setProperty:@YES forKey:@"big"];
        [LinkCell setProperty:@56 forKey:@"height"];
        [LinkCell setProperty:@(iconTransparentBG) forKey:@"iconTransparentBG"];
    }

    return LinkCell;
}

// Tweak settings
- (NSArray *)specifiers {
    if (!_specifiers) {        
        _specifiers = [NSMutableArray arrayWithArray:@[
            [self newLinkCellWithTitle:@"Donate" detailTitle:@"Consider donating to support this tweak <3" url:@"https://ko-fi.com/socuul" iconURL:@"https://i.imgur.com/g4U5AMi.png" iconTransparentBG:YES],

            // Section 1: General
            [self newSectionWithTitle:@"General" footer:nil],
            [self newSwitchCellWithTitle:@"Hide Meta AI" detailTitle:@"Hides the meta ai buttons/functionality within the app" key:@"hide_meta_ai" changeAction:nil],
            [self newSwitchCellWithTitle:@"Copy description" detailTitle:@"Copy the text descriptions by long pressing" key:@"copy_description" changeAction:nil],
            [self newSwitchCellWithTitle:@"Use detailed color picker" detailTitle:@"Long press on the eyedropper tool in stories to customize the text color more precisely" key:@"detailed_color_picker" changeAction:nil],
            [self newSwitchCellWithTitle:@"Enable hidden text effects/styles" detailTitle:@"Unlocks the use of every effect/style for text in stories" key:@"enable_hidden_texteffectsstyles" changeAction:nil],
            [self newSwitchCellWithTitle:@"Do not save recent searches" detailTitle:@"Search bars will no longer save your recent searches" key:@"no_recent_searches" changeAction:nil],
            [self newSwitchCellWithTitle:@"Hide notes tray" detailTitle:@"Hides the notes tray in the dm inbox" key:@"hide_notes_tray" changeAction:nil],
            [self newSwitchCellWithTitle:@"Hide friends map" detailTitle:@"Hides the friends map icon in the notes tray" key:@"hide_friends_map" changeAction:nil],

            // Section 2: Feed
            [self newSectionWithTitle:@"Feed" footer:nil],
            [self newSwitchCellWithTitle:@"Hide ads" detailTitle:@"Removes all ads from the Instagram app" key:@"hide_ads" changeAction:nil],
            [self newSwitchCellWithTitle:@"Hide stories tray" detailTitle:@"Hides the story tray at the top and within your feed" key:@"hide_stories_tray" changeAction:nil],
            [self newSwitchCellWithTitle:@"Hide entire feed" detailTitle:@"Removes all content from your home feed, including posts" key:@"hide_entire_feed" changeAction:nil],
            [self newSwitchCellWithTitle:@"No suggested posts" detailTitle:@"Removes suggested posts from your feed" key:@"no_suggested_post" changeAction:nil],
            [self newSwitchCellWithTitle:@"No suggested for you" detailTitle:@"Hides suggested accounts for you to follow" key:@"no_suggested_account" changeAction:nil],
            [self newSwitchCellWithTitle:@"No suggested reels" detailTitle:@"Hides suggested reels to watch" key:@"no_suggested_reels" changeAction:nil],
            [self newSwitchCellWithTitle:@"No suggested threads posts" detailTitle:@"Hides suggested threads posts" key:@"no_suggested_threads" changeAction:nil],
            
            // Section 3: Save media
            [self newSectionWithTitle:@"Save media" footer:nil],
            [self newSwitchCellWithTitle:@"Download feed posts" detailTitle:@"Long-press with finger(s) to download posts in the home tab" key:@"dw_feed_posts" changeAction:nil],
            [self newSwitchCellWithTitle:@"Download reels" detailTitle:@"Long-press with finger(s) on a reel to download" key:@"dw_reels" changeAction:nil],
            [self newSwitchCellWithTitle:@"Download stories" detailTitle:@"Long-press with finger(s) while viewing someone's story to download" key:@"dw_story" changeAction:nil],
            [self newSwitchCellWithTitle:@"Save profile picture" detailTitle:@"On someone's profile, click their profile picture to enlarge it, then hold to download" key:@"save_profile" changeAction:nil],
            [self newStepperCellWithTitle:@"Use %@ %@ for long-press" key:@"dw_finger_count" min:1 max:5 step:1 label:@"fingers" singularLabel:@"finger"],
            [self newStepperCellWithTitle:@"%@ %@ press to download" key:@"dw_finger_duration" min:0 max:10 step:0.25 label:@"sec" singularLabel:@"sec"],

            // Section 4: Stories and Messages
            [self newSectionWithTitle:@"Stories and messages" footer:nil],
            [self newSwitchCellWithTitle:@"Keep deleted message" detailTitle:@"Keeps deleted direct messages in the chat" key:@"keep_deleted_message" changeAction:nil],
            [self newSwitchCellWithTitle:@"Disable screenshot detection" detailTitle:@"Removes the screenshot-prevention features for visual messages in DMs" key:@"remove_screenshot_alert" changeAction:nil],
            [self newSwitchCellWithTitle:@"Unlimited replay of direct stories" detailTitle:@"Replays direct messages normal/once stories unlimited times (toggle with image check icon)" key:@"unlimited_replay" changeAction:nil],
            [self newSwitchCellWithTitle:@"Disable sending read receipts" detailTitle:@"Removes the seen text for others when you view a message (toggle with message check icon)" key:@"remove_lastseen" changeAction:nil],
            [self newSwitchCellWithTitle:@"Disable story seen receipt" detailTitle:@"Hides the notification for others when you view their story" key:@"no_seen_receipt" changeAction:nil],
            [self newSwitchCellWithTitle:@"Disable view-once limitations" detailTitle:@"Makes view-once messages behave like normal visual messages (loopable/pauseable)" key:@"disable_view_once_limitations" changeAction:nil],
            
            // Section 5: Confirm actions
            [self newSectionWithTitle:@"Confirm actions" footer:nil],
            [self newSwitchCellWithTitle:@"Confirm like: Posts" detailTitle:@"Shows an alert when you click the like button on posts or stories to confirm the like" key:@"like_confirm" changeAction:nil],
            [self newSwitchCellWithTitle:@"Confirm like: Reels" detailTitle:@"Shows an alert when you click the like button on reels to confirm the like" key:@"like_confirm_reels" changeAction:nil],
            [self newSwitchCellWithTitle:@"Confirm follow" detailTitle:@"Shows an alert when you click the follow button to confirm the follow" key:@"follow_confirm" changeAction:nil],
            [self newSwitchCellWithTitle:@"Confirm repost" detailTitle:@"Shows an alert when you click the repost button to confirm before resposting" key:@"repost_confirm" changeAction:nil],
            [self newSwitchCellWithTitle:@"Confirm call" detailTitle:@"Shows an alert when you click the audio/video call button to confirm before calling" key:@"call_confirm" changeAction:nil],
            [self newSwitchCellWithTitle:@"Confirm voice messages" detailTitle:@"Shows an alert to confirm before sending a voice message" key:@"voice_message_confirm" changeAction:nil],
            [self newSwitchCellWithTitle:@"Confirm shh mode" detailTitle:@"Shows an alert to confirm before toggling disappearing messages" key:@"shh_mode_confirm" changeAction:nil],
            [self newSwitchCellWithTitle:@"Confirm sticker interaction" detailTitle:@"Shows an alert when you click a sticker on someone's story to confirm the action" key:@"sticker_interact_confirm" changeAction:nil],
            [self newSwitchCellWithTitle:@"Confirm posting comment" detailTitle:@"Shows an alert when you click the post comment button to confirm" key:@"post_comment_confirm" changeAction:nil],
            [self newSwitchCellWithTitle:@"Confirm changing theme" detailTitle:@"Shows an alert when you change a dm channel theme to confirm" key:@"change_direct_theme_confirm" changeAction:nil],
            [self newSwitchCellWithTitle:@"Confirm follow requests" detailTitle:@"Shows an alert when you accept/decline a follow request" key:@"follow_request_confirm" changeAction:nil],
            
            // Section 6: Focus/Distractions
            [self newSectionWithTitle:@"Focus/Distractions" footer:nil],
            [self newSwitchCellWithTitle:@"Hide explore posts grid" detailTitle:@"Hides the grid of suggested posts on the explore/search tab" key:@"hide_explore_grid" changeAction:nil],
            [self newSwitchCellWithTitle:@"Hide trending searches" detailTitle:@"Hides the trending searches under the explore search bar" key:@"hide_trending_searches" changeAction:nil],
            [self newSwitchCellWithTitle:@"No suggested chats" detailTitle:@"Hides the suggested broadcast channels in direct messages" key:@"no_suggested_chats" changeAction:nil],
            [self newSwitchCellWithTitle:@"No suggested users" detailTitle:@"Hides all suggested users for you to follow, outside your feed" key:@"no_suggested_users" changeAction:nil],
            [self newSwitchCellWithTitle:@"Disable scrolling reels" detailTitle:@"Prevents reels from being scrolled to the next video" key:@"disable_scrolling_reels" changeAction:nil],

            // Section 7: Hide navigation tabs
            [self newSectionWithTitle:@"Navigation" footer:nil],
            [self newSwitchCellWithTitle:@"Hide explore tab" detailTitle:@"Hides the explore/search tab on the bottom navbar" key:@"hide_explore_tab" changeAction:nil],
            [self newSwitchCellWithTitle:@"Hide create tab" detailTitle:@"Hides the create/camera tab on the bottom navbar" key:@"hide_create_tab" changeAction:nil],
            [self newSwitchCellWithTitle:@"Hide reels tab" detailTitle:@"Hides the reels tab on the bottom navbar" key:@"hide_reels_tab" changeAction:nil],

            // Section 8: Security
            [self newSectionWithTitle:@"Security" footer:nil],
            [self newSwitchCellWithTitle:@"Padlock" detailTitle:@"Locks Instagram with biometrics/password" key:@"padlock" changeAction:nil],

            // Section 9: Debugging
            [self newSectionWithTitle:@"Debugging" footer:nil],
            [self newSwitchCellWithTitle:@"Enable FLEX gesture" detailTitle:@"Allows you to hold 5 fingers on the screen to open the FLEX explorer" key:@"flex_instagram" changeAction:@selector(FLEXAction:)],
            [self newSwitchCellWithTitle:@"Open FLEX on app focus" detailTitle:@"Automatically opens the FLEX explorer when the app is focused" key:@"flex_app_start" changeAction:nil],
            [self newSwitchCellWithTitle:@"Disable safe mode" detailTitle:@"Makes Instagram not reset settings after subsequent crashes" key:@"disable_safe_mode" changeAction:nil],

            // Section 10: Credits
            [self newSectionWithTitle:@"Credits" footer:[NSString stringWithFormat:@"SCInsta %@\n\nInstagram v%@", SCIVersionString, [SCIUtils IGVersionString]]],
            [self newLinkCellWithTitle:@"Developer" detailTitle:@"SoCuul" url:@"https://socuul.dev" iconURL:@"https://i.imgur.com/WSFMSok.png" iconTransparentBG:NO],
            [self newLinkCellWithTitle:@"View Repo" detailTitle:@"View the tweak's source code on GitHub" url:@"https://github.com/SoCuul/SCInsta" iconURL:@"https://i.imgur.com/BBUNzeP.png" iconTransparentBG:YES]
        ]];
        
        [self collectDynamicSpecifiersFromArray:_specifiers];
    }
    
    return _specifiers;
}

- (void)reloadSpecifiers {
    [super reloadSpecifiers];
    
    [self collectDynamicSpecifiersFromArray:self.specifiers];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasDynamicSpecifiers) {
        PSSpecifier *dynamicSpecifier = [self specifierAtIndexPath:indexPath];
        BOOL __block shouldHide = false;
        
        [self.dynamicSpecifiers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSMutableArray *specifiers = obj;
            if ([specifiers containsObject:dynamicSpecifier]) {
                shouldHide = [self shouldHideSpecifier:dynamicSpecifier];
                
                UITableViewCell *specifierCell = [dynamicSpecifier propertyForKey:PSTableCellKey];
                specifierCell.clipsToBounds = shouldHide;
            }
        }];
        if (shouldHide) {
            return 0;
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (void)collectDynamicSpecifiersFromArray:(NSArray *)array {
    if (!self.dynamicSpecifiers) {
        self.dynamicSpecifiers = [NSMutableDictionary new];
        
    } else {
        [self.dynamicSpecifiers removeAllObjects];
    }
    
    for (PSSpecifier *specifier in array) {
        NSString *dynamicSpecifierRule = [specifier propertyForKey:@"dynamicRule"];
        
        if (dynamicSpecifierRule.length > 0) {
            NSArray *ruleComponents = [dynamicSpecifierRule componentsSeparatedByString:@", "];
            
            if (ruleComponents.count == 3) {
                NSString *opposingSpecifierID = [ruleComponents objectAtIndex:0];
                if ([self.dynamicSpecifiers objectForKey:opposingSpecifierID]) {
                    NSMutableArray *specifiers = [[self.dynamicSpecifiers objectForKey:opposingSpecifierID] mutableCopy];
                    [specifiers addObject:specifier];
                    
                    
                    [self.dynamicSpecifiers removeObjectForKey:opposingSpecifierID];
                    [self.dynamicSpecifiers setObject:specifiers forKey:opposingSpecifierID];
                } else {
                    [self.dynamicSpecifiers setObject:[NSMutableArray arrayWithArray:@[specifier]] forKey:opposingSpecifierID];
                }
                
            } else {
                [NSException raise:NSInternalInconsistencyException format:@"dynamicRule key requires three components (Specifier ID, Comparator, Value To Compare To). You have %ld of 3 (%@) for specifier '%@'.", ruleComponents.count, dynamicSpecifierRule, [specifier propertyForKey:PSTitleKey]];
            }
        }
    }
    
    self.hasDynamicSpecifiers = (self.dynamicSpecifiers.count > 0);
}
- (DynamicSpecifierOperatorType)operatorTypeForString:(NSString *)string {
    NSDictionary *operatorValues = @{ @"==" : @(EqualToOperatorType), @"!=" : @(NotEqualToOperatorType), @">" : @(GreaterThanOperatorType), @"<" : @(LessThanOperatorType) };
    return [operatorValues[string] intValue];
}
- (BOOL)shouldHideSpecifier:(PSSpecifier *)specifier {
    if (specifier) {
        NSString *dynamicSpecifierRule = [specifier propertyForKey:@"dynamicRule"];
        NSArray *ruleComponents = [dynamicSpecifierRule componentsSeparatedByString:@", "];
        
        PSSpecifier *opposingSpecifier = [self specifierForID:[ruleComponents objectAtIndex:0]];
        id opposingValue = [self readPreferenceValue:opposingSpecifier];
        id requiredValue = [ruleComponents objectAtIndex:2];
        
        if ([opposingValue isKindOfClass:NSNumber.class]) {
            DynamicSpecifierOperatorType operatorType = [self operatorTypeForString:[ruleComponents objectAtIndex:1]];
            
            switch (operatorType) {
                case EqualToOperatorType:
                    return ([opposingValue intValue] == [requiredValue intValue]);
                    break;
                    
                case NotEqualToOperatorType:
                    return ([opposingValue intValue] != [requiredValue intValue]);
                    break;
                    
                case GreaterThanOperatorType:
                    return ([opposingValue intValue] > [requiredValue intValue]);
                    break;
                    
                case LessThanOperatorType:
                    return ([opposingValue intValue] < [requiredValue intValue]);
                    break;
            }
        }
        
        if ([opposingValue isKindOfClass:NSString.class]) {
            return [opposingValue isEqualToString:requiredValue];
        }
        
        if ([opposingValue isKindOfClass:NSArray.class]) {
            return [opposingValue containsObject:requiredValue];
        }
    }
    
    return NO;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSUserDefaults *Prefs = [NSUserDefaults standardUserDefaults];
    [Prefs setValue:value forKey:[specifier identifier]];

    NSLog(@"[SCInsta] Set user default. Key: %@ | Value: %@", [specifier identifier], value);
    
    if (self.hasDynamicSpecifiers) {
        NSString *specifierID = [specifier propertyForKey:PSIDKey];
        PSSpecifier *dynamicSpecifier = [self.dynamicSpecifiers objectForKey:specifierID];
        
        if (dynamicSpecifier) {
            [self.table beginUpdates];
            [self.table endUpdates];
        }
    }
}
- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSUserDefaults *Prefs = [NSUserDefaults standardUserDefaults];
    return [Prefs valueForKey:[specifier identifier]]?:[specifier properties][@"default"];
}

- (void)FLEXAction:(UISwitch *)sender {
    if (sender.isOn) {
        [[objc_getClass("FLEXManager") sharedManager] showExplorer];

        NSLog(@"[SCInsta] FLEX explorer: Enabled");
    }
    else {
        [[objc_getClass("FLEXManager") sharedManager] hideExplorer];

        NSLog(@"[SCInsta] FLEX explorer: Disabled");
    }
}
@end