# SCInsta
A feature-rich tweak for Instagram on iOS!\
`Version v1.0.0-beta` | `Tested on Instagram 414.0.0`

---

> [!NOTE]
> ⚙️ &nbsp;To modify SCInsta's settings, check out [this page](https://github.com/SoCuul/SCInsta/wiki/Modify-Settings) for help\
> ❓ &nbsp;If you have any questions or need help with the tweak, visit the [Discussions](https://github.com/SoCuul/SCInsta/discussions) tab
>
> ✨ &nbsp;If you have a feature request, [click here](https://github.com/SoCuul/SCInsta/issues/new/choose)\
> 🐛 &nbsp;If you have a bug report, [click here](https://github.com/SoCuul/SCInsta/issues/new/choose)
> 

---

# Installation
>[!IMPORTANT]
> Which type of device are you planning on installing this tweak on?
> - Jailbroken/TrollStore device -> [Download pre-built tweak](https://github.com/SoCuul/SCInsta/releases/latest)
> - Standard iOS device -> [Visit the wiki to create an IPA file](https://github.com/SoCuul/SCInsta/wiki/Building-IPA)

# Features
### General
- Hide Meta AI
- Copy description
- Use detailed color picker
- Enable hidden text effects/styles
- Do not save recent searches
- Hide notes tray
- Hide friends map

### Feed
- Hide ads
- Hide stories tray
- Hide entire feed
- No suggested posts
- No suggested for you (accounts)
- No suggested reels
- No suggested threads posts

### Save media
- Download feed posts
- Download reels
- Download stories
- Save profile picture

### Story and messages
- Keep deleted message
- Disable screenshot detection
- Unlimited replay of direct stories
- Disabling sending read receipts
- Disable story seen receipt
- Disable view-once limitations

### Confirm actions
- Confirm like: Posts (and stories)
- Confirm like: Reels
- Confirm follow
- Confirm call
- Confirm voice messages
- Confirm shh mode (disappearing messages)
- Confirm sticker interaction
- Confirm posting comment
- Confirm changing direct message theme

### Focus/Distractions
- Hide explore posts grid
- Hide trending searches
- No suggested chats
- No suggested users
- Disable scrolling reels

### Navigation
- Hide explore tab
- Hide create tab
- Hide reels tab

### Security
- Padlock (require biometric authentication to open the app)

### Optimization
- Automatically clears unneeded cache folders, reducing the size of your Instagram installation

### Built-in Tweak Settings
[How to modify SCInsta settings](https://github.com/SoCuul/SCInsta/wiki/Modify-Settings)

# In-App Screenshots

|                                             |                                             |                                             |
|:-------------------------------------------:|:-------------------------------------------:|:-------------------------------------------:|
| <img src="https://i.imgur.com/EZIktAw.png"> | <img src="https://i.imgur.com/aA3g1Vw.png"> | <img src="https://i.imgur.com/QdyFbo4.png"> |
| <img src="https://i.imgur.com/Ydd61cZ.png"> | <img src="https://i.imgur.com/XGOn3lY.png"> | <img src="https://i.imgur.com/n4GFWl8.png"> |

# Building from source
### Prerequisites
- XCode + Command-Line Developer Tools
- [Homebrew](https://brew.sh/#install)
- [CMake](https://formulae.brew.sh/formula/cmake#default) (`brew install cmake`)
- [Theos](https://theos.dev/docs/installation)
- [cyan](https://github.com/asdfzxcvbn/pyzule-rw?tab=readme-ov-file#install-instructions) **\*only required for sideloading**
- [ipapatch](https://github.com/asdfzxcvbn/ipapatch/releases/latest) **\*only required for sideloading**

### Setup
1. Install iOS 14.5 frameworks for theos
   1. [Click to download iOS SDKs](https://github.com/xybp888/iOS-SDKs/archive/refs/heads/master.zip)
   2. Unzip, then copy the `iPhoneOS14.5.sdk` folder into `~/theos/sdks`
2. Clone SCInsta repo from GitHub: `git clone --recurse-submodules https://github.com/SoCuul/SCInsta`
3. **For sideloading**: Download a decrypted Instagram IPA from a trusted source, making sure to rename it to `com.burbn.instagram.ipa`.
   Then create a folder called `packages` inside of the `SCInsta` folder, and move the Instagram IPA file into it. 

### Run build script
```sh
$ chmod +x build.sh
$ ./build.sh <sideload/rootless/rootful>
```

# Contributing
Contributions to this tweak are greatly appreciated. Feel free to create a pull request if you would like to contribute.

If you do not have the technical knowledge to contribute to the codebase, improvements to the documentation are always welcome!

# Support the project
SCInsta takes a lot of time to develop, as the Instagram app is ever-changing and difficult to keep up with. Additionally, I'm still a student which doesn't leave me much time to work on this tweak.

If you'd like to support my work, you can donate to my [ko-fi page](https://ko-fi.com/socuul)!\
There's many other ways to support this project however, by simply sharing a link to this tweak with others who would like it!

Seeing people use this tweak is what keeps me motivated to keep working on it ❤️

# Credits
- Huge thanks to [@BandarHL](https://github.com/BandarHL) for creating the original BHInstagram project, which SCInsta is based upon.
