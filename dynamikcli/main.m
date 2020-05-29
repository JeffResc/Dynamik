#import <stdio.h>
#import <string.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import "DynamikController.h"

void performSelectorWithInteger(id parent, SEL selector, NSInteger integer) {
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[parent methodSignatureForSelector:selector]];
    [inv setTarget:parent];
    [inv setSelector:selector];
    [inv setArgument:&integer atIndex:2];
    [inv invoke];
}

int setWallpaper(NSString *subreddit, int numberOfPostsGrabbed, int location, bool parallax, bool nsfwFilter, bool highQualityFilter) {
  int tries = 0;
  while (tries < 5) {
    UIImage *newImage = [[DynamikController sharedInstance] getImageFromReddit:subreddit numberOfPostsGrabbed:numberOfPostsGrabbed nsfwFiltered:nsfwFilter];
    if (newImage == nil) {
      NSLog(@"Recieved invalid image, trying again...");
      tries++;
      continue;
    }
    dlopen("/System/Library/PrivateFrameworks/SpringBoardFoundation.framework/SpringBoardFoundation", RTLD_LAZY);
    void *SBUIServs = dlopen("/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/SpringBoardUIServices", RTLD_LAZY);

    id lightOptions = [[objc_getClass("SBFWallpaperOptions") alloc] init];
    id darkOptions = [[objc_getClass("SBFWallpaperOptions") alloc] init];

    if (!parallax) {
        performSelectorWithInteger(lightOptions, @selector(setParallaxFactor:), 0);
        performSelectorWithInteger(darkOptions, @selector(setParallaxFactor:), 0);
    }

    if (@available(iOS 13, *)) {
        int (*SBSUIWallpaperSetImages)(NSDictionary *imagesDict, NSDictionary *optionsDict, int location, int interfaceStyle) = dlsym(SBUIServs, "SBSUIWallpaperSetImages");

        performSelectorWithInteger(lightOptions, @selector(setWallpaperMode:), 1);
        performSelectorWithInteger(darkOptions, @selector(setWallpaperMode:), 2);
        SBSUIWallpaperSetImages(@{@"light":newImage, @"dark":newImage}, @{@"light":lightOptions, @"dark":darkOptions}, location, UIUserInterfaceStyleDark);
    }
    else {
        void (*SBSUIWallpaperSetImage)(UIImage *image, NSDictionary *optionsDict, NSInteger location) = dlsym(SBUIServs, "SBSUIWallpaperSetImage");
        SBSUIWallpaperSetImage(newImage, lightOptions, location);
    }
    return 0;
  }

  NSLog(@"Tried too many times, quitting...");
  return 1;
}

void displayUsage() {
    printf("Usage: dynamikcli -s [subreddit] -m [# of posts] [location] [-p] [-n] [-q]\n");
    printf("       -s\tSubreddit\n");
    printf("       For a full list of suggested subreddits, see the GitHub page at https://github.com/JeffResc/Dynamik/\n");
    printf("\n");
    printf("       -m\tNumber of posts\n");
    printf("       Number of hot posts to grab, it will choose a random image from one of them\n");
    printf("\n");
    printf("       -l\tSet only the lock screen wallpaper\n");
    printf("       -h\tSet only the home screen wallpaper\n");
    printf("       -b\tSet both wallpapers\n");
    printf("       Choose between -h, -l, and -b. Do not specify more than one\n");
    printf("\n");
    printf("       -p\tEnable parallax (optional parameter - parallax is off by default)\n");
    printf("\n");
    printf("       -n\tEnable NSFW Filter (optional parameter - NSFW Filter is off by default)\n");
    printf("\n");
    printf("       -q\tEnable High-Quality Filter (optional parameter - High-Quality Filter is off by default)\n");
    printf("\n");
    printf("       --help\tShow this help page\n");
    printf("\n");
    printf("       All arguments are required except -p\n");
}

int main(int argc, char *argv[], char *envp[]) {
    if (argc == 1 || !strcmp(argv[1], "--help")) {
        displayUsage();
        return 1;
    }

    int location;
    int numberOfPostsGrabbed;
    NSString *subreddit;
    bool parallax = false;
    bool nsfwFilter = false;
    bool highQualityFilter = false;

    int args = 0;
    for (int i = 1; i < argc; i++) { //parse the arguments
        if (!strcmp(argv[i], "-s")) {
          subreddit = [NSString stringWithUTF8String:argv[i + 1]];
          args++;
        } else if (!strcmp(argv[i], "-m")) {
          numberOfPostsGrabbed = atoi(argv[i + 1]);
          if (numberOfPostsGrabbed > 0 && numberOfPostsGrabbed <= 10) {
            args++;
          }
        } else if (!strcmp(argv[i], "-l")) {
          location = 1;
          args++;
        } else if (!strcmp(argv[i], "-h")) {
          location = 2;
          args++;
        } else if (!strcmp(argv[i], "-b")) {
          location = 3;
          args++;
        } else if (!strcmp(argv[i], "-p")) {
          parallax = true;
        } else if (!strcmp(argv[i], "-n")) {
          nsfwFilter = true;
        } else if (!strcmp(argv[i], "-q")) {
          highQualityFilter = true;
        }
    }

    if (args == 3) {
      return setWallpaper(subreddit, numberOfPostsGrabbed, location, parallax, nsfwFilter, highQualityFilter);
    } else {
      displayUsage();
      return 1;
    }
    return 0;
}
