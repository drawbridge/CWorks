//
//  CWorks.h
//  CWorks
//
//  Created by Anupam Tulsyan on 3/28/12.
//  Copyright (c) 2012 Conversionworks.org. 
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

//
// Support for ARC
//


#if __has_feature(objc_arc)

#define HAS_ARC 1
#define RETAIN(_o) (_o)
#define RELEASE(_o) 
#define AUTORELEASE(_o) (_o)

#else

#define HAS_ARC 0
#define RETAIN(_o) [(_o) retain]
#define RELEASE(_o) [(_o) release]
#define AUTORELEASE(_o) [(_o) autorelease]

#endif

#import <Foundation/Foundation.h>

@interface CWorks : NSObject{
  
}

+ (void) recordClick:(NSString*) appID forAdNetwork:(NSString*)adNetwork uniqueId:(NSString*)uniqueId;

+ (NSDictionary*) getClicks:(NSString*) appID;

+ (void) recordImpression:(NSString*) appID forAdNetwork:(NSString*)adNetwork uniqueId:(NSString*)uniqueId;

+ (NSDictionary*) getImpressions:(NSString*) appID;

@end
