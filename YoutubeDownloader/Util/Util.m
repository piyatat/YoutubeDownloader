//
//  Util.m
//  YoutubeDownloader
//
//  Created by Tei on 9/6/14.
//  Copyright (c) 2014 B2HOME. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "Util.h"

@implementation Util

static Util *sharedUtil = nil;

+ (Util *)sharedUtil
{
    if (sharedUtil == nil) {
        sharedUtil = [[super allocWithZone:NULL] init];

        [sharedUtil initialize];
    }
    return sharedUtil;
}

- (void)initialize
{
    isLoadingImage = NO;
    cachedImageURLQueueList = [[NSMutableArray alloc] init];
    cachedImageDictionary = [[NSMutableDictionary alloc] init];
    notFoundImageURLList = [[NSMutableArray alloc] init];
}

- (void)dealloc
{

}

#pragma mark - Image Caching Method

- (NSImage *)cachedImageAtURL:(NSURL *)imageURL
       withPlacementImageName:(NSString *)placementImageName
                    isLoading:(BOOL *)loading
{
    // Get image from cache
    NSImage *image = [cachedImageDictionary objectForKey:imageURL];

    // image is not cached yet
    if (image == nil) {
        // check if it is in not found list
        if ([notFoundImageURLList containsObject:imageURL]) {
            *loading = NO;
            if (placementImageName) {
                return [NSImage imageNamed:placementImageName];
            } else {
                return nil;
            }
        }

        *loading = YES;
        // check if it is in the queue
        if ([cachedImageURLQueueList containsObject:imageURL] == NO) {
            [cachedImageURLQueueList addObject:imageURL];
        }

        if (isLoadingImage == NO) {
            // Start loading image
            isLoadingImage = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                while ([cachedImageURLQueueList count] > 0) {
                    NSURL *_imageURL = [cachedImageURLQueueList objectAtIndex:0];
                    NSImage *_image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:_imageURL]];
                    if (_image) {
                        //                        BBLog(@"Cached image at URL: %@", _imageURL);
                        [cachedImageDictionary setObject:_image
                                                  forKey:_imageURL];
                    } else {
                        //                        BBLog(@"Image not found for URL: %@", _imageURL);
                        [notFoundImageURLList addObject:_imageURL];
                    }

                    [cachedImageURLQueueList removeObjectAtIndex:0];

                    [[NSNotificationCenter defaultCenter] postNotificationName:ImageCachedNotificationKey object:_imageURL];
                }
                isLoadingImage = NO;
            });
        }

        if (placementImageName) {
            return [NSImage imageNamed:placementImageName];
        } else {
            return nil;
        }
    } else {
        *loading = NO;
        return image;
    }
}

- (void)clearCachedImage
{
    [cachedImageDictionary removeAllObjects];
}

@end
