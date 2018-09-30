#import <UIKit/UIKit.h>
#import <substrate.h>

typedef void (^RCTResponseSenderBlock)(NSArray *response);

@interface DCDMessageTableViewCell : UITableViewCell
@property (readonly)NSDictionary *message;
@property (readonly)UILabel *usernameLabel;
@end

NSString *lastMessageID = @"";
UIPasteboard *pasteboard = UIPasteboard.generalPasteboard;

%hook DCDMessageTableViewCell
-(void)handleLongPress:(id)arg1
{
	lastMessageID = self.message[@"id"];
    return %orig;
}
%end
/*
%hook DCDAvatarView
- (void)setURLString:(id)arg1
{
    NSString *user_id = arg1;
    user_id = [user_id substringFromIndex:[user_id rangeOfString:@"avatars/"].location + [@"avatars/" length]];
    user_id = [user_id substringToIndex:[user_id rangeOfString:@"/"].location];
	%log(@"DDevMode: User ID from Avatar URL: ", user_id);
	%orig;
}
%end*/

%hook RCTActionSheetManager
- (void)showActionSheetWithOptions:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback
{
	NSMutableArray *array = [options[@"options"] mutableCopy];
	if([array containsObject:@"User Settings"])
	{
		//Text
		NSInteger destruct1 = [options[@"destructiveButtonIndex"] integerValue];
		NSInteger destruct2 = [options[@"destructiveButtonIndex"] integerValue] + 1;
		NSInteger cancel1 = [options[@"cancelButtonIndex"] integerValue];
		NSInteger cancel2 = [options[@"cancelButtonIndex"] integerValue] + 1;
		[array insertObject:@"Copy Message ID" atIndex:destruct1];
		NSDictionary * newOptions = @{ @"cancelButtonIndex" : @(cancel2), 
		@"destructiveButtonIndex" : @(destruct2), 
		@"options" : array };
		//Callback
		RCTResponseSenderBlock newCallback = ^void(NSArray *response)
		{
			NSLog(@"DDevMode: ActionSheet response: %@", response);
			int index = [response[0] integerValue];
			if (index < destruct1)
			{
				NSLog(@"DDevMode: ActionSheet: %d -> %d", index, index);
				callback(@[@(index)]);
			}
			else if (index > destruct1)
			{
				NSLog(@"DDevMode: ActionSheet: %d -> %d", index, index - 1);
				callback(@[@(index - 1)]);
			}
			else
			{
				NSLog(@"DDevMode: ActionSheet: destructiveButtonIndex -> Custom!");
				pasteboard.string = lastMessageID;
				callback(@[@(cancel1)]);
			}
		};
		//Call orig with our options
		%orig(newOptions, newCallback);
	}
	else
	{
		%orig;
	}
}
%end