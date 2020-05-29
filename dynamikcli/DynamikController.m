/*
  This file is heavily based off StellaeController.m by Zachary Thomas Paul <LacertosusThemes@gmail.com>
  Thank you to Stellae for making this part easy :)
  https://github.com/LacertosusRepo/Open-Source-Tweaks/blob/master/Stellae/StellaeController.m
*/
#import "DynamikController.h"

@implementation DynamikController
  +(id)sharedInstance {
    static DynamikController *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
      sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
  }

  -(id)init {
    if(self = [super init]) {
      NSLog(@"Dynamik || Initalized");
    }
    return self;
  }

  // Thanks! - https://stackoverflow.com/a/5042365
  - (BOOL)dataIsValidImage:(NSData *)data {
      uint8_t c;
      [data getBytes:&c length:1];

      switch (c) {
      case 0xFF:
          return true;
      case 0x89:
          return true;
      }
      return false;
  }

  -(UIImage *)getImageFromReddit:(NSString *)subredditName numberOfPostsGrabbed:(int)postsGrabbed nsfwFiltered:(BOOL)nsfwFilter {
    NSString *finalRedditURL = [self getFinalRedditURL:subredditName numberOfPostsGrabbed:postsGrabbed];
    NSDictionary *redditJSONDictionary = [self getRedditJSONData:finalRedditURL];
    int postNumber = arc4random_uniform([redditJSONDictionary[@"data"][@"children"] count]);
    BOOL postIsNSFW = [self postIsNSFW:postNumber fromDictionary:redditJSONDictionary];

    if(nsfwFilter && postIsNSFW) {
      NSLog(@"Dynamik || NSFW filter is on and post is NSFW - %d", postIsNSFW);
      return nil;
    } else {
      NSString *redditImageURL = redditJSONDictionary[@"data"][@"children"][postNumber][@"data"][@"url"];
      NSLog(@"Dynamik || Found image at URL: %@", redditImageURL);
      if([redditImageURL containsString:@"imgur.com"] && ![redditImageURL containsString:@"i.imgur"]) {
        redditImageURL = [redditImageURL stringByAppendingString:@".jpg"];
      }

      NSString *postURL = @"https://reddit.com";
      postURL = [postURL stringByAppendingString:redditJSONDictionary[@"data"][@"children"][postNumber][@"data"][@"permalink"]];
      [self saveURL:postURL forKey:@"currentRedditURL"];
      [self saveURL:redditImageURL forKey:@"currentImageURL"];

      NSLog(@"Dynamik || Downloading image...");
      NSData *redditImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:redditImageURL]];
      NSLog(@"Dynamik || Finished downloading...");
      if ([self dataIsValidImage:redditImageData]) {
        UIImage *redditUIImage = [UIImage imageWithData:redditImageData];
        return redditUIImage;
      } else {
        NSLog(@"Dynamik || Image invalid, not PNG or JPEG...");
        return nil;
      }
    }

    return nil;
  }

  -(NSString *)getFinalRedditURL:(NSString *)subredditName numberOfPostsGrabbed:(int)postsGrabbed {
    if([subredditName isEqualToString:@""] || [subredditName containsString:@"r/"] || [subredditName containsString:@" "]) {
      NSLog(@"Dynamik || Error with subredditName - %@", subredditName);
      subredditName = @"spaceporn";
    }

    NSString *redditURL = [NSString stringWithFormat:@"https://reddit.com/r/%@/hot.json?limit=%d", subredditName, postsGrabbed];
    return redditURL;
  }

  -(NSDictionary *)getRedditJSONData:(NSString *)redditURL {
    NSError *error = nil;
    NSURL *redditJSONURL = [NSURL URLWithString:redditURL];
    NSData *redditJSONData = [NSData dataWithContentsOfURL:redditJSONURL];
    NSDictionary *redditJSONDictionary = nil;

    if(redditJSONData != nil) {
      redditJSONDictionary = [NSJSONSerialization JSONObjectWithData:redditJSONData options:0 error:&error];
    } else {
      NSLog(@"Dynamik || Error getting data - %@", error);
      return nil;
    }

    return redditJSONDictionary;
  }

  -(BOOL)postIsNSFW:(int)postNumber fromDictionary:(NSDictionary *)dictionary {
    return [dictionary[@"data"][@"children"][postNumber][@"data"][@"over_18"] boolValue];
  }

  -(void)saveURL:(NSString *)URL forKey:(NSString *)key {
    NSString *file = @"/User/Library/Preferences/com.jeffresc.dynamiksaveddata.plist";
    NSMutableDictionary *saveddata = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
    [saveddata setObject:URL forKey:key];
    [saveddata writeToFile:file atomically:YES];
  }

  -(NSArray *)excludedProviders {
    return [NSArray arrayWithObjects:@"gfycat.com", nil];
  }
@end
