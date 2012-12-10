//
//  CWorks.m
//  CWorks
//
//  Created by Anupam Tulsyan on 3/28/12.
//  Copyright (c) 2012 ConversionWorks.org.
//

/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "CWorks.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIPasteboard.h>
#import <UIKit/UIKit.h>


static NSString * kConversionWorksKey = @"CWorks";
static NSString * kConversionWorksDomain = @"Conversionworks.org";
static int kMaxPasteBoardItems = 50;

//private utility functions
@interface CWorks (Private)

+ (NSString *) _getMD5:(NSString *) str;
+ (NSString *) _getNormalizedAdNetworkName:(NSString *) adNetwork;
+ (NSMutableDictionary *) _getDictFromPasteBoard:(id)pboard;
+ (void) _setDict:(id)dict forPasteboard:(id)pboard;

@end

@implementation CWorks

/*
 private method to get the md5 of a string.
 it is used to hash the appid and network name before storing to the pasteboard.
 */
+ (NSString *) _getMD5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

/*
 private method to normalize the ad network name.
 */
+ (NSString *) _getNormalizedAdNetworkName:(NSString *)adNetwork
{
	return [[adNetwork lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

/*
 Private method to get the existing dictionary for a given pasteboard.
 returns nil if the dictionary is not present.
 */
+ (NSMutableDictionary*) _getDictFromPasteboard:(id)pboard
{

	id item = [pboard dataForPasteboardType:kConversionWorksDomain];

	if (item)
		item = [NSKeyedUnarchiver unarchiveObjectWithData:item];

	// return an instance of a MutableDictionary
	return [NSMutableDictionary dictionaryWithDictionary:(item == nil || [item isKindOfClass:[NSDictionary class]]) ? item : nil];
}

/*
 Private method to set the dictionary for the given pasteboard. It overrides the existing dictionary if any
 */
+ (void) _setDict:(id)dict forPasteboard:(id)pboard
{
	[pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forPasteboardType:kConversionWorksDomain];
}

/*
 Public Method to record a click event by a publisher.
 This method checks for existence of current pasteboard and adds the current click to it.
 The unique id passed by advertiser will finally help the ad network to tie this click to an app install event.
 The appId is hashed using md5 to protect data.
 */
+ (void) recordClick:(NSString*) appID forAdNetwork:(NSString*)adNetwork uniqueId:(NSString*)uniqueId
{
	//check for null or empty string
	if([appID length] == 0 || [adNetwork length] == 0 || [uniqueId length] == 0)
	{
		return;
	}
	else
	{
		NSString * pbName = [NSString stringWithFormat:@"%@.%@", kConversionWorksKey, [self _getMD5:appID]];

		UIPasteboard* convPB = [UIPasteboard pasteboardWithName:pbName create:YES];
		[convPB setPersistent:YES];

		NSMutableDictionary * dict = [self _getDictFromPasteboard:convPB];

		if(dict == nil)
		{
			dict = [[[NSMutableDictionary alloc] init] retain];
		}
		else if([dict count] >= kMaxPasteBoardItems)
		{
			[dict removeObjectForKey:[[dict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				return [obj1 compare:obj2];
			}] objectAtIndex:0]];
		}

		//add the current click withkey specific to network and values as timestamp.
		NSTimeInterval timeInterVal = [[NSDate date] timeIntervalSince1970];
		NSString * timestamp = [NSString stringWithFormat:@"%d", (int)timeInterVal];
		NSString * networkKey = [NSString stringWithFormat:@"c.%@.%@",[self _getNormalizedAdNetworkName:adNetwork],uniqueId];

		[dict setObject:timestamp forKey:networkKey];
		[self _setDict:dict forPasteboard:convPB];
	}
}

/*
 Public Method to record a impression event by a publisher.
 This method checks for existence of current pasteboard and adds the current click to it.
 The unique id passed by advertiser will finally help the ad network to tie this impression to an app install event.
 The appId is hashed using md5 to protect data.
 */
+ (void) recordImpression:(NSString *)appID forAdNetwork:(NSString *)adNetwork uniqueId:(NSString *)uniqueId
{
	//check for null or empty string
	if([appID length] == 0 || [adNetwork length] == 0 || [uniqueId length] == 0)
	{
		return;
	}
	else
	{
		NSString * pbName = [NSString stringWithFormat:@"%@.%@", kConversionWorksKey, [self _getMD5:appID]];

		UIPasteboard* convPB = [UIPasteboard pasteboardWithName:pbName create:YES];
		[convPB setPersistent:YES];

		NSMutableDictionary * dict = [self _getDictFromPasteboard:convPB];

		if(dict == nil)
		{
			dict = [[[NSMutableDictionary alloc] init] retain];
		}
		else if([dict count] >= kMaxPasteBoardItems)
		{
			[dict removeObjectForKey:[[dict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				return [obj1 compare:obj2];
			}] objectAtIndex:0]];
		}
		//add the current click withkey specific to network and values as timestamp.
		NSTimeInterval timeInterVal = [[NSDate date] timeIntervalSince1970];
		NSString * timestamp = [NSString stringWithFormat:@"%d", (int)timeInterVal];
		NSString * networkKey = [NSString stringWithFormat:@"i.%@.%@",[self _getNormalizedAdNetworkName:adNetwork],uniqueId];
		
		[dict setObject:timestamp forKey:networkKey];
		[self _setDict:dict forPasteboard:convPB];
	}
}

/*
 Public Method to return all the clicks for a particular app ID. This method needs to be called when the app
 is first activated by the user.
 It returns a dictionary of key value where key is composed of network name
 and timestamp. After returning the dictionary this method clears the existing pasteboard for all the clicks
 generate for this app.
 */
+ (NSDictionary*) getClicks:(NSString*) appID
{
	if([appID length] == 0)
	{
		return nil;
	}
	else
	{
		NSString * pbName = [NSString stringWithFormat:@"%@.%@", kConversionWorksKey, [self _getMD5:appID]];

		UIPasteboard * convPB = [UIPasteboard pasteboardWithName:pbName create:NO];

		NSMutableDictionary * clicksDict = [[[NSMutableDictionary alloc] init] autorelease];
		if(convPB != nil)
		{
			NSMutableDictionary * dict = [self _getDictFromPasteboard:convPB];


			//get all the clicks
			for(NSString *key in dict)
			{
				if([key hasPrefix:@"c"])
				{
					NSString * value = (NSString *)[dict objectForKey:key];
					if(value != nil)
					{
						[clicksDict setObject:value forKey:key];
					}
				}
			}
			[dict removeObjectsForKeys:[clicksDict allKeys]];
			//not removing the pasteboard because if there is a re-install event the pasteboard will be invalid
			[self _setDict:dict forPasteboard:convPB];

			return clicksDict;
		}
		else
		{
			return nil;
		}
	}
}

/*
 Public Method to return all the Impressions for a particular app ID. This method needs to be called 
 when the app is first activated by the user.
 It returns a dictionary of key value where key is composed of network name
 and timestamp. After returning the dictionary this method clears the existing pasteboard 
 for all the impressions generate for this app.
 */
+ (NSDictionary*) getImpressions:(NSString*) appID
{
	if([appID length] == 0)
	{
		return nil;
	}
	else
	{
		NSString * pbName = [NSString stringWithFormat:@"%@.%@", kConversionWorksKey, [self _getMD5:appID]];

		UIPasteboard * convPB = [UIPasteboard pasteboardWithName:pbName create:NO];

		NSMutableDictionary * impressionsDict = [[[NSMutableDictionary alloc] init] autorelease];
		if(convPB != nil)
		{
			NSMutableDictionary * dict = [self _getDictFromPasteboard:convPB];


			//get all the impressions
			for(NSString *key in dict)
			{
				if([key hasPrefix:@"i"])
				{
					NSString * value = (NSString *)[dict objectForKey:key];
					if(value != nil)
					{
						[impressionsDict setObject:value forKey:key];
					}
				}
			}

			//remove all the impressions from the dict
			[dict removeObjectsForKeys:[impressionsDict allKeys]];

			//not removi ng the pasteboard because if there is a re-install event the pasteboard will be invalid
			[self _setDict:dict forPasteboard:convPB];

			return impressionsDict;
		}
		else
		{
			return nil;
		}
	}
}

@end
