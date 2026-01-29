#import "TweakSettings.h"

@implementation SCITweakSettings

///
/// This returns an array of sections, with each section consisting of a dictionary
///
/// `"title"`: The section title (leave blank for no title)
///
/// `"rows"`: An array of **SCISetting** classes, potentially containing a "navigationCellWithTitle" initializer to allow for nested setting pages.
///
/// `"footer`: The section footer (leave blank for no footer)
///

+ (NSArray *)sections {
    return @[
        @{
            @"title": @"",
            @"rows": @[
                [SCISetting linkCellWithTitle:@"Donate" subtitle:@"Consider donating to support this tweak's development!" icon:[SCISymbol symbolWithName:@"heart.circle.fill" color:[UIColor systemPinkColor] size:20.0] url:@"https://ko-fi.com/SoCuul"]
            ]
        },
        @{
            @"title": @"",
            @"rows": @[
                [SCISetting navigationCellWithTitle:@"General"
                                           subtitle:@""
                                               icon:[SCISymbol symbolWithName:@"gear"]
                                        navSections:@[@{
                                            @"title": @"",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Hide Meta AI" subtitle:@"Hides the meta ai buttons/functionality within the app" defaultsKey:@"hide_meta_ai"],
                                                [SCISetting switchCellWithTitle:@"Copy description" subtitle:@"Copy description text fields by long-pressing on them" defaultsKey:@"copy_description"],
                                                [SCISetting switchCellWithTitle:@"Use detailed color picker" subtitle:@"Long press on the eyedropper tool in stories to customize the text color more precisely" defaultsKey:@"detailed_color_picker"],
                                                [SCISetting switchCellWithTitle:@"Do not save recent searches" subtitle:@"Search bars will no longer save your recent searches" defaultsKey:@"no_recent_searches"],
                                                [SCISetting switchCellWithTitle:@"Hide notes tray" subtitle:@"Hides the notes tray in the dm inbox" defaultsKey:@"hide_notes_tray"],
                                                [SCISetting switchCellWithTitle:@"Hide friends map" subtitle:@"Hides the friends map icon in the notes tray" defaultsKey:@"hide_friends_map"],
                                                [SCISetting switchCellWithTitle:@"Enable teen app icons" subtitle:@"When enabled, hold down on the Instagram logo to change the app icon" defaultsKey:@"teen_app_icons" requiresRestart:YES],
                                            ]
                                        }]
                ],
                [SCISetting navigationCellWithTitle:@"Feed"
                                           subtitle:@""
                                               icon:[SCISymbol symbolWithName:@"rectangle.stack"]
                                        navSections:@[@{
                                            @"title": @"",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Hide ads" subtitle:@"Removes all ads from the Instagram app" defaultsKey:@"hide_ads"],
                                                [SCISetting switchCellWithTitle:@"Hide stories tray" subtitle:@"Hides the story tray at the top and within your feed" defaultsKey:@"hide_stories_tray"],
                                                [SCISetting switchCellWithTitle:@"Hide entire feed" subtitle:@"Removes all content from your home feed, including posts" defaultsKey:@"hide_entire_feed"],
                                                [SCISetting switchCellWithTitle:@"No suggested posts" subtitle:@"Removes suggested posts from your feed" defaultsKey:@"no_suggested_post"],
                                                [SCISetting switchCellWithTitle:@"No suggested for you" subtitle:@"Hides suggested accounts for you to follow" defaultsKey:@"no_suggested_account"],
                                                [SCISetting switchCellWithTitle:@"No suggested reels" subtitle:@"Hides suggested reels to watch" defaultsKey:@"no_suggested_reels"],
                                                [SCISetting switchCellWithTitle:@"No suggested threads posts" subtitle:@"Hides suggested threads posts" defaultsKey:@"no_suggested_threads"]
                                            ]
                                        }]
                ],
                [SCISetting navigationCellWithTitle:@"Saving"
                                           subtitle:@""
                                               icon:[SCISymbol symbolWithName:@"tray.and.arrow.down"]
                                        navSections:@[@{
                                            @"title": @"",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Download feed posts" subtitle:@"Long-press with finger(s) to download posts in the home tab" defaultsKey:@"dw_feed_posts"],
                                                [SCISetting switchCellWithTitle:@"Download reels" subtitle:@"Long-press with finger(s) on a reel to download" defaultsKey:@"dw_reels"],
                                                [SCISetting switchCellWithTitle:@"Download stories" subtitle:@"Long-press with finger(s) while viewing someone's story to download" defaultsKey:@"dw_story"],
                                                [SCISetting switchCellWithTitle:@"Save profile picture" subtitle:@"On someone's profile, click their profile picture to enlarge it, then hold to download" defaultsKey:@"save_profile"]
                                            ]
                                        },
                                        @{
                                            @"title": @"Customize gestures",
                                            @"rows": @[
                                                [SCISetting stepperCellWithTitle:@"Finger count for long-press" subtitle:@"Downloads with %@ %@" defaultsKey:@"dw_finger_count" min:1 max:5 step:1 label:@"fingers" singularLabel:@"finger"],
                                                [SCISetting stepperCellWithTitle:@"Long-press hold time" subtitle:@"Press finger(s) for %@ %@" defaultsKey:@"dw_finger_duration" min:0 max:10 step:0.25 label:@"sec" singularLabel:@"sec"]
                                            ]
                                        }]
                ],
                [SCISetting navigationCellWithTitle:@"Stories and messages"
                                           subtitle:@""
                                               icon:[SCISymbol symbolWithName:@"rectangle.portrait.on.rectangle.portrait.angled"]
                                        navSections:@[@{
                                            @"title": @"",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Keep deleted messages" subtitle:@"Saves deleted messages in chat conversations" defaultsKey:@"keep_deleted_message"],
                                                [SCISetting switchCellWithTitle:@"Disable screenshot detection" subtitle:@"Removes the screenshot-prevention features for visual messages in DMs" defaultsKey:@"remove_screenshot_alert"],
                                                [SCISetting switchCellWithTitle:@"Unlimited replay of direct stories" subtitle:@"Replays direct messages normal/once stories unlimited times (toggle with image check icon)" defaultsKey:@"unlimited_replay"],
                                                [SCISetting switchCellWithTitle:@"Disable sending read receipts" subtitle:@"Removes the seen text for others when you view a message (toggle with message check icon)" defaultsKey:@"remove_lastseen"],
                                                [SCISetting switchCellWithTitle:@"Disable story seen receipt" subtitle:@"Hides the notification for others when you view their story" defaultsKey:@"no_seen_receipt"],
                                                [SCISetting switchCellWithTitle:@"Disable view-once limitations" subtitle:@"Makes view-once messages behave like normal visual messages (loopable/pauseable)" defaultsKey:@"disable_view_once_limitations"]
                                            ]
                                        }]
                ],
                [SCISetting navigationCellWithTitle:@"Confirm actions"
                                           subtitle:@""
                                               icon:[SCISymbol symbolWithName:@"checkmark"]
                                        navSections:@[@{
                                            @"title": @"",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Confirm like: Posts" subtitle:@"Shows an alert when you click the like button on posts or stories to confirm the like" defaultsKey:@"like_confirm"],
                                                [SCISetting switchCellWithTitle:@"Confirm like: Reels" subtitle:@"Shows an alert when you click the like button on reels to confirm the like" defaultsKey:@"like_confirm_reels"]
                                            ]
                                        },
                                        @{
                                            @"title": @"",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Confirm follow" subtitle:@"Shows an alert when you click the follow button to confirm the follow" defaultsKey:@"follow_confirm"],
                                                [SCISetting switchCellWithTitle:@"Confirm repost" subtitle:@"Shows an alert when you click the repost button to confirm before resposting" defaultsKey:@"repost_confirm"],
                                                [SCISetting switchCellWithTitle:@"Confirm call" subtitle:@"Shows an alert when you click the audio/video call button to confirm before calling" defaultsKey:@"call_confirm"],
                                                [SCISetting switchCellWithTitle:@"Confirm voice messages" subtitle:@"Shows an alert to confirm before sending a voice message" defaultsKey:@"voice_message_confirm"],
                                                [SCISetting switchCellWithTitle:@"Confirm follow requests" subtitle:@"Shows an alert when you accept/decline a follow request" defaultsKey:@"follow_request_confirm"],
                                                [SCISetting switchCellWithTitle:@"Confirm shh mode" subtitle:@"Shows an alert to confirm before toggling disappearing messages" defaultsKey:@"shh_mode_confirm"],
                                                [SCISetting switchCellWithTitle:@"Confirm posting comment" subtitle:@"Shows an alert when you click the post comment button to confirm" defaultsKey:@"post_comment_confirm"],
                                                [SCISetting switchCellWithTitle:@"Confirm changing theme" subtitle:@"Shows an alert when you change a chat theme to confirm" defaultsKey:@"change_direct_theme_confirm"],
                                                [SCISetting switchCellWithTitle:@"Confirm sticker interaction" subtitle:@"Shows an alert when you click a sticker on someone's story to confirm the action" defaultsKey:@"sticker_interact_confirm"]
                                            ]
                                        }]
                ],
                [SCISetting navigationCellWithTitle:@"Focus/distractions"
                                           subtitle:@""
                                               icon:[SCISymbol symbolWithName:@"moon"]
                                        navSections:@[@{
                                            @"title": @"",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Hide explore posts grid" subtitle:@"Hides the grid of suggested posts on the explore/search tab" defaultsKey:@"hide_explore_grid"],
                                                [SCISetting switchCellWithTitle:@"Hide trending searches" subtitle:@"Hides the trending searches under the explore search bar" defaultsKey:@"hide_trending_searches"],
                                                [SCISetting switchCellWithTitle:@"No suggested chats" subtitle:@"Hides the suggested broadcast channels in direct messages" defaultsKey:@"no_suggested_chats"],
                                                [SCISetting switchCellWithTitle:@"No suggested users" subtitle:@"Hides all suggested users for you to follow, outside your feed" defaultsKey:@"no_suggested_users"],
                                                [SCISetting switchCellWithTitle:@"Disable scrolling reels" subtitle:@"Prevents reels from being scrolled to the next video" defaultsKey:@"disable_scrolling_reels"],
                                            ]
                                        }]
                ],
                [SCISetting navigationCellWithTitle:@"Navigation"
                                           subtitle:@""
                                               icon:[SCISymbol symbolWithName:@"dock.rectangle"]
                                        navSections:@[@{
                                            @"title": @"",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Hide feed tab" subtitle:@"Hides the feed/home tab on the bottom navbar" defaultsKey:@"hide_feed_tab" requiresRestart:YES],
                                                [SCISetting switchCellWithTitle:@"Hide explore tab" subtitle:@"Hides the explore/search tab on the bottom navbar" defaultsKey:@"hide_explore_tab" requiresRestart:YES],
                                                [SCISetting switchCellWithTitle:@"Hide reels tab" subtitle:@"Hides the reels tab on the bottom navbar" defaultsKey:@"hide_reels_tab" requiresRestart:YES]
                                            ]
                                        }]
                ]
            ]
        },
        @{
            @"title": @"",
            @"rows": @[
                [SCISetting navigationCellWithTitle:@"Debug"
                                           subtitle:@""
                                               icon:[SCISymbol symbolWithName:@"ladybug"]
                                        navSections:@[@{
                                            @"title": @"FLEX",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Enable FLEX gesture" subtitle:@"Allows you to hold 5 fingers on the screen to open the FLEX explorer" defaultsKey:@"flex_instagram"],
                                                [SCISetting switchCellWithTitle:@"Open FLEX on app launch" subtitle:@"Automatically opens the FLEX explorer when the app launches" defaultsKey:@"flex_app_launch"],
                                                [SCISetting switchCellWithTitle:@"Open FLEX on app focus" subtitle:@"Automatically opens the FLEX explorer when the app is focused" defaultsKey:@"flex_app_start"]
                                            ]
                                        },
                                        @{
                                            @"title": @"SCInsta",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Show tweak settings on app launch" subtitle:@"Automatically opens the SCInsta settings when the app launches" defaultsKey:@"tweak_settings_app_launch"]
                                            ]
                                        },
                                        @{
                                            @"title": @"Instagram",
                                            @"rows": @[
                                                [SCISetting switchCellWithTitle:@"Disable safe mode" subtitle:@"Makes Instagram not reset settings after subsequent crashes (at your own risk)" defaultsKey:@"disable_safe_mode"]
                                            ]
                                        },
                                        // @{
                                        //     @"title": @"Example",
                                        //     @"rows": @[
                                        //         [SCISetting staticCellWithTitle:@"Static Cell" subtitle:@"" icon:[SCISymbol symbolWithName:@"tablecells"]],
                                        //         [SCISetting switchCellWithTitle:@"Switch Cell" subtitle:@"Tap the switch" defaultsKey:@"test_switch_cell"],
                                        //         [SCISetting switchCellWithTitle:@"Switch Cell (Restart)" subtitle:@"Tap the switch" defaultsKey:@"test_switch_cell_restart" requiresRestart:YES],
                                        //         [SCISetting stepperCellWithTitle:@"Stepper cell" subtitle:@"I have %@%@" defaultsKey:@"test_stepper_cell" min:-10 max:1000 step:5.5 label:@"$" singularLabel:@"$"],
                                        //         [SCISetting linkCellWithTitle:@"Link Cell" subtitle:@"Using icon" icon:[SCISymbol symbolWithName:@"link" color:[UIColor systemTealColor] size:20.0] url:@"https://google.com"],
                                        //         [SCISetting linkCellWithTitle:@"Link Cell" subtitle:@"Using image" imageUrl:@"https://i.imgur.com/c9CbytZ.png" url:@"https://google.com"],
                                        //         [SCISetting buttonCellWithTitle:@"Button Cell"
                                        //                                    subtitle:@""
                                        //                                        icon:[SCISymbol symbolWithName:@"oval.inset.filled"]
                                        //                                      action:^(void) { [SCIUtils showConfirmation:^(void){}]; }
                                        //         ],
                                        //         [SCISetting navigationCellWithTitle:@"Navigation Cell"
                                        //                                    subtitle:@""
                                        //                                        icon:[SCISymbol symbolWithName:@"rectangle.stack"]
                                        //                                 navSections:@[@{
                                        //                                     @"title": @"",
                                        //                                     @"rows": @[]
                                        //                                 }]
                                        //         ]
                                        //     ],
                                        //     @"footer": @"Example"
                                        // }
                                        ]
                ]
            ]
        },
        @{
            @"title": @"Credits",
            @"rows": @[
                [SCISetting linkCellWithTitle:@"Developer" subtitle:@"SoCuul" imageUrl:@"https://i.imgur.com/c9CbytZ.png" url:@"https://socuul.dev"],
                [SCISetting linkCellWithTitle:@"View Repo" subtitle:@"View the tweak's source code on GitHub" imageUrl:@"https://i.imgur.com/BBUNzeP.png" url:@"https://github.com/SoCuul/SCInsta"]
            ],
            @"footer": [NSString stringWithFormat:@"SCInsta %@\n\nInstagram v%@", SCIVersionString, [SCIUtils IGVersionString]]
        }
    ];
}   

+ (NSString *)title {
    return @"SCInsta Settings";
}

@end
