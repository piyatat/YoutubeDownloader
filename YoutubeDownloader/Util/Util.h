//
//  Util.h
//  YoutubeDownloader
//
//  Created by Tei on 9/6/14.
//  Copyright (c) 2014 B2HOME. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ImageCachedNotificationKey          @"BBNotification_ImageCache"

@interface Util : NSObject
{
    BOOL isLoadingImage;
    
    // store image url to load in order
    NSMutableArray *cachedImageURLQueueList;
    // cached image dictionary
    NSMutableDictionary *cachedImageDictionary;
    // not found image url
    NSMutableArray *notFoundImageURLList;
}

@property (nonatomic, readonly) BOOL isiPhone;
@property (nonatomic, readonly) NSMutableDictionary *userProfileDictionary;

+ (Util *)sharedUtil;
- (void)initialize;

- (NSImage *)cachedImageAtURL:(NSURL *)imageURL
       withPlacementImageName:(NSString *)placementImageName
                    isLoading:(BOOL *)loading;
- (void)clearCachedImage;

@end
