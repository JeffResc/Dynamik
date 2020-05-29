#include "DynamikRootListController.h"
#import "MTimePickerCell.h"
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <Cephei/HBRespringController.h>
#include <spawn.h>

@implementation DynamikRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = UIColorFromRGB(0xc7a794);
		appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
		self.hb_appearanceSettings = appearanceSettings;
		self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)];
		self.respringButton.tintColor = UIColorFromRGB(0xc7a794);
		self.navigationItem.rightBarButtonItem = self.respringButton;
	}
	return self;
}

-(void)updateRedditImage {
	UIAlertController *updateImageAlert = [UIAlertController alertControllerWithTitle:@"Dynamik" message:@"Are you sure you want to update the wallpaper? You can't save it once its changed!" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.jeffresc.dynamik-runCommand"), nil, nil, true);
	}];
	[updateImageAlert addAction:cancelAction];
	[updateImageAlert addAction:confirmAction];
	[self presentViewController:updateImageAlert animated:YES completion:nil];
}

-(void)saveImage {
	UIAlertController *saveImageAlert = [UIAlertController alertControllerWithTitle:@"Dynamik" message:@"Saving current wallpaper..." preferredStyle:UIAlertControllerStyleAlert];
	[self presentViewController:saveImageAlert animated:YES completion:^{
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.jeffresc.dynamikprefs-saveImage"), nil, nil, true);
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[saveImageAlert dismissViewControllerAnimated:YES completion:nil];
		});
	}];
}

-(void)openCurrentImageSource {
	NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.dynamiksaveddata.plist"];
	NSString *currentShownImageURL = [preferences objectForKey:@"currentShownImageURL"];
	if([currentShownImageURL isEqualToString:@""] || currentShownImageURL == nil) {
		UIAlertController *openCurrentImageSourceError = [UIAlertController alertControllerWithTitle:@"Dynamik" message:@"No image URL currently saved! Wait for the wallpaper to automatically update or manually update it yourself for this to be available." preferredStyle:UIAlertControllerStyleAlert];
		[self presentViewController:openCurrentImageSourceError animated:YES completion:^{
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[openCurrentImageSourceError dismissViewControllerAnimated:YES completion:nil];
			});
		}];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentShownImageURL] options:@{} completionHandler:nil];
	}
}

- (void)respring:(id)sender {
	[HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=Dynamik"]];
}

- (void)PayPal_Donate_Link {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/JeffRescignano"]];
}

- (void)GitHub_Source_Code_Link {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/JeffResc/Dynamik"]];
}

- (void)Packix_Depiction_Page_Link {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://repo.packix.com/package/com.jeffresc.dynamik/"]];
}

- (void)Twitter_Profile_Link {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/JeffRescignano"]];
}
@end
