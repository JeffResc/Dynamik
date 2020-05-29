/*
  This file is heavily based off StellaeController.h by Zachary Thomas Paul <LacertosusThemes@gmail.com>
  Thank you to Stellae for making this part easy :)
  https://github.com/LacertosusRepo/Open-Source-Tweaks/blob/master/Stellae/StellaeController.h
*/

@interface DynamikController : NSObject
+(id)sharedInstance;
-(id)init;
-(BOOL)dataIsValidImage:(NSData *)data;
-(UIImage *)getImageFromReddit:(NSString *)subredditName numberOfPostsGrabbed:(int)postsGrabbed nsfwFiltered:(BOOL)nsfwFilter;
-(NSString *)getFinalRedditURL:(NSString *)subredditName numberOfPostsGrabbed:(int)postsGrabbed;
-(NSDictionary *)getRedditJSONData:(NSString *)redditURL;
-(BOOL)postIsNSFW:(int)postNumber fromDictionary:(NSDictionary *)dictionary;
-(void)saveURL:(NSString *)URL forKey:(NSString *)key;
-(NSArray *)excludedProviders;
@end
