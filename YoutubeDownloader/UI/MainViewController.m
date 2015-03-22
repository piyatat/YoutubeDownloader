//
//  MainViewController.m
//  YoutubeDownloader
//
//  Created by Tei on 9/6/14.
//  Copyright (c) 2014 B2HOME. All rights reserved.
//

#import "MainViewController.h"

#import "AFNetworking.h"
#import "GTLYouTube.h"
#import "XCDYouTubeClient.h"

#import "Util.h"
#import "VideoCellView.h"


#pragma mark - MainViewController

@interface MainViewController ()

@property (nonatomic, strong, readwrite) AFURLSessionManager    *sessionManager;
@property (nonatomic, strong, readwrite) GTLServiceYouTube      *youtubeService;

- (IBAction)onBtnClicked:(id)sender;
- (void)onCellBtnClicked:(NSButton *)sender;
- (void)updateUI;
- (void)enableUI;
- (void)disableUI;

@end


@implementation MainViewController

@synthesize list_view, view_control;
@synthesize txt_url, loading_indicator, btn_fetch;
@synthesize btn_selectAll, btn_selectNone, btn_download, btn_stop;
@synthesize txt_key, btn_key;

@synthesize sessionManager, youtubeService;

- (id)init
{
    self = [super initWithNibName:@"MainView" bundle:nil];
    if (self) {
        itemType = BBItemTypeNone;
        isDownloading = NO;
        list_video = [NSMutableArray array];
        list_video_select = [NSMutableArray array];
        list_video_downloadProgress = [NSMutableArray array];
        downloadingVideoIndex = -1;

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        [self.sessionManager setDownloadTaskDidWriteDataBlock:
         ^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite)
        {
            if (downloadingVideoIndex >= 0 && downloadingVideoIndex < [list_video_downloadProgress count]) {
                int progress = (int)(100.0 * totalBytesWritten / totalBytesExpectedToWrite);
                int oldProgress = [[list_video_downloadProgress objectAtIndex:downloadingVideoIndex] intValue];

                if (progress != oldProgress) {
                    [list_video_downloadProgress replaceObjectAtIndex:downloadingVideoIndex withObject:[NSNumber numberWithInt:progress]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.list_view reloadData];
                    });
                }
            }
        }];

        self.youtubeService = [[GTLServiceYouTube alloc] init];
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        self.youtubeService.shouldFetchNextPages = NO;

        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        self.youtubeService.retryEnabled = YES;

        [[NSNotificationCenter defaultCenter] addObserverForName:ImageCachedNotificationKey object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSURL *imageURL = note.object;
            if (imageURL) {
                [self.list_view reloadData];
            }
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateUI];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.list_view.dataSource = nil;
    self.list_view.delegate = nil;
}

#pragma mark - View Action Method

- (IBAction)onBtnClicked:(id)sender
{
    if (sender == self.btn_key) {
        self.youtubeService.APIKey = self.txt_key.stringValue;
        [self updateUI];
    }
    else if (sender == self.btn_fetch) {
        [self fetchVideo];
    }
    else if (sender == self.btn_selectAll) {
        for (int i = 0; i < [list_video_select count]; i++) {
            [list_video_select replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
        }
        [self.list_view reloadData];
    } else if (sender == self.btn_selectNone) {
        for (int i = 0; i < [list_video_select count]; i++) {
            [list_video_select replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        }
        [self.list_view reloadData];
    }
    else if (sender == self.btn_download) {
        NSOpenPanel *openDialog = [NSOpenPanel openPanel];
        [openDialog setCanChooseFiles:NO];
        [openDialog setCanChooseDirectories:YES];
        [openDialog setAllowsMultipleSelection:NO];

        if ([openDialog runModal] == NSOKButton) {
            NSArray *urls = [openDialog URLs];
            if ([urls count] > 0) {
                if (directory) {
                    directory = nil;
                }

                NSURL *url = [urls objectAtIndex:0];
                directory = [[[[url absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy];

                isDownloading = YES;
                [self downloadVideo];
            }
        }
    } else if (sender == self.btn_stop) {
        isDownloading = NO;
        NSArray *downloadTaskList = [self.sessionManager downloadTasks];
        for (NSURLSessionDownloadTask *task in downloadTaskList) {
            [task cancel];
        }
        [self.loading_indicator stopAnimation:self];
        [self enableUI];
        [self.btn_stop setEnabled:NO];
        downloadingVideoIndex = -1;
    }
}

- (void)onCellBtnClicked:(NSButton *)sender
{
    if (isDownloading) {
        return;
    }

    NSInteger row = [self.list_view rowForView:sender];
    if (row >= 0 && row < [self numberOfRowsInTableView:self.list_view]) {
        if (sender.state == NSOnState) {
            [list_video_select replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:YES]];
        } else if (sender.state == NSOffState) {
            [list_video_select replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:NO]];
        }
        [self.list_view reloadData];
    }
}

- (void)updateUI
{
    [self.btn_fetch setEnabled:NO];
    [self.btn_download setEnabled:NO];
    [self.btn_stop setEnabled:NO];

    if (self.youtubeService.APIKey && [self.youtubeService.APIKey length] > 0) {
        if (self.txt_url.stringValue && [self.txt_url.stringValue length] > 0) {
            [self.btn_fetch setEnabled:YES];

            if ([list_video count] > 0) {
                [self.btn_download setEnabled:YES];
            }
        } else {
            [self.btn_fetch setEnabled:NO];
        }
    }
}

- (void)enableUI
{
    [self.txt_key setEnabled:YES];
    [self.btn_key setEnabled:YES];

    [self.txt_url setEnabled:YES];
    [self.btn_fetch setEnabled:YES];

    [self.btn_selectAll setEnabled:YES];
    [self.btn_selectNone setEnabled:YES];
    [self.btn_download setEnabled:YES];
    [self.btn_stop setEnabled:YES];

    [self updateUI];
}

- (void)disableUI
{
    [self.txt_key setEnabled:NO];
    [self.btn_key setEnabled:NO];

    [self.txt_url setEnabled:NO];
    [self.btn_fetch setEnabled:NO];

    [self.btn_selectAll setEnabled:NO];
    [self.btn_selectNone setEnabled:NO];
    [self.btn_download setEnabled:NO];
    [self.btn_stop setEnabled:NO];
}

#pragma mark - Private Method

- (void)fetchVideo
{
    itemType = BBItemTypeNone;
    downloadingVideoIndex = -1;
    [list_video removeAllObjects];
    [list_video_select removeAllObjects];
    [list_video_downloadProgress removeAllObjects];

    GTLQueryYouTube *query = nil;

    [self.loading_indicator startAnimation:self];
    [self disableUI];

    NSString *itemID = nil;
    NSString *urlString = self.txt_url.stringValue;
    NSRange range = [urlString rangeOfString:@"list="];
    if (range.length > 0) {
        // Playlist ID
        itemType = BBItemTypePlaylist;
        urlString = [urlString substringFromIndex:(range.location + range.length)];
        range = [urlString rangeOfString:@"&"];
        if (range.length > 0) {
            urlString = [urlString substringToIndex:range.location];
        }
        itemID = urlString;
    } else {
        range = [urlString rangeOfString:@"v="];
        if (range.length > 0) {
            // Video ID
            itemType = BBItemTypeVideo;
            urlString = [urlString substringFromIndex:(range.location + range.length)];
            range = [urlString rangeOfString:@"&"];
            if (range.length > 0) {
                urlString = [urlString substringToIndex:range.location];
            }
            itemID = urlString;
        }
    }

    if (itemID == nil) {
        NSRunAlertPanel(@"No ID Found", @"There is no videoID or playlistID specified in the URL!!!", @"OK", nil, nil);
        [self.loading_indicator stopAnimation:self];
        [self enableUI];
        return;
    }

    switch (itemType) {
        case BBItemTypeVideo: // Video ID
        {
            query = [GTLQueryYouTube queryForVideosListWithPart:@"snippet"];
            query.identifier = itemID;
            break;
        }
        case BBItemTypePlaylist: // Playlist ID
        {
            query = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"snippet"];
            query.playlistId = itemID;
            break;
        }
        default:
            break;
    }

    query.maxResults = 50;
    [self.youtubeService executeQuery:query
                    completionHandler:
     ^(GTLServiceTicket *ticket, id object, NSError *error) {
         if (error) {
             NSLog(@"Error: %@", error);
             GTLErrorObject* const errorObject = error.userInfo[kGTLStructuredErrorKey];
             NSLog(@"Error from YouTube API: %@", errorObject.data);
         }
         NSLog(@"Response: %@", object);
         if ([object isKindOfClass:[GTLYouTubeVideoListResponse class]]) {
             GTLYouTubeVideoListResponse *response = (GTLYouTubeVideoListResponse *)object;
             [list_video addObjectsFromArray:response.items];

             for (int i = 0; i < [list_video count]; i++) {
                 [list_video_select addObject:[NSNumber numberWithBool:YES]];
                 [list_video_downloadProgress addObject:[NSNumber numberWithInt:0]];
             }
         }
         else if ([object isKindOfClass:[GTLYouTubePlaylistItemListResponse class]]) {
             GTLYouTubePlaylistItemListResponse *response = (GTLYouTubePlaylistItemListResponse *)object;
             [list_video addObjectsFromArray:response.items];

             for (int i = 0; i < [list_video count]; i++) {
                 [list_video_select addObject:[NSNumber numberWithBool:YES]];
                 [list_video_downloadProgress addObject:[NSNumber numberWithInt:0]];
             }
         }

         dispatch_async(dispatch_get_main_queue(), ^{
             [self.loading_indicator stopAnimation:self];
             [self enableUI];
             [self.list_view reloadData];
         });
     }];
}

- (void)downloadVideo
{
    if (isDownloading == NO) {
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        downloadingVideoIndex++;

        if (downloadingVideoIndex >= 0 && downloadingVideoIndex < [list_video count]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loading_indicator startAnimation:self];
                [self disableUI];
                [self.btn_stop setEnabled:YES];
            });

            NSNumber *select = [list_video_select objectAtIndex:downloadingVideoIndex];
            NSNumber *progress = [list_video_downloadProgress objectAtIndex:downloadingVideoIndex];

            if ([select boolValue] == NO || [progress intValue] >= 100) {
                // Not selected video, or already completed (progress == 100%)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.loading_indicator stopAnimation:self];
                    [self enableUI];
                    [self.btn_stop setEnabled:NO];
                    [self downloadVideo];
                });
                return;
            }

            NSString *itemID = nil;
            NSString *itemTitle = nil;
            id result = [list_video objectAtIndex:downloadingVideoIndex];
            if ([result isKindOfClass:[GTLYouTubeVideo class]]) {
                GTLYouTubeVideo *videoResult = (GTLYouTubeVideo *)result;
                itemID = videoResult.identifier;
                itemTitle = videoResult.snippet.title;
            } else if ([result isKindOfClass:[GTLYouTubePlaylistItem class]]) {
                GTLYouTubePlaylistItem *playlistResult = (GTLYouTubePlaylistItem *)result;
                itemID = [playlistResult.snippet.resourceId.JSON objectForKey:@"videoId"];
                itemTitle = playlistResult.snippet.title;
            } else {
                // TODO: handle unexpected result object
            }

            NSLog(@"ItemType: %@", [result class]);
            NSLog(@"VideoID: %@", itemID);

            [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:itemID completionHandler:
             ^(XCDYouTubeVideo *video, NSError *error) {
                 if (error) {
                     NSLog(@"Error: %@", error);
                 }

                 if (video) {
                     NSDictionary *streamURLs = video.streamURLs;
                     NSURL *url = streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?: streamURLs[@(XCDYouTubeVideoQualityHD720)] ?: streamURLs[@(XCDYouTubeVideoQualityMedium360)] ?: streamURLs[@(XCDYouTubeVideoQualitySmall240)];
                     NSLog(@"VideoURL: %@", url);

                     NSURLRequest *request = [NSURLRequest requestWithURL:url];
                     NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                         NSString *fileName = [NSString stringWithFormat:@"%@.%@", itemID, [[response suggestedFilename] pathExtension]];
                         NSString *filePath = [directory stringByAppendingPathComponent:fileName];
                         NSLog(@"VideoPath: %@", filePath);

                         return [NSURL fileURLWithPath:filePath];
                     } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                         NSLog(@"File downloaded to: %@", filePath);
                         if (error) {
                             NSLog(@"Error: %@", error);
                         }

                         if (filePath) {
                             NSCharacterSet *notAllowedChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
                             NSString *fileName = [[itemTitle componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@" "];
                             fileName = [NSString stringWithFormat:@"%@.%@", fileName, [[response suggestedFilename] pathExtension]];
                             NSString *newFilePath = [directory stringByAppendingPathComponent:fileName];
                             NSError *fileError = nil;
                             [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:[NSURL fileURLWithPath:newFilePath] error:&fileError];
                             if (fileError) {
                                 NSLog(@"FileError: %@", fileError);
                             }
                         }

                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.loading_indicator stopAnimation:self];
                             [self enableUI];
                             [self.btn_stop setEnabled:NO];
                             [self downloadVideo];
                         });
                     }];
                     [downloadTask resume];
                 } else {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.loading_indicator stopAnimation:self];
                         [self enableUI];
                         [self.btn_stop setEnabled:NO];
                         [self downloadVideo];
                     });
                 }
            }];
        } else {
            // Download done
            isDownloading = NO;
        }
    });
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [list_video count];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    // Get a new ViewCell
    VideoCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    [cellView.btn_check setTarget:self];
    [cellView.btn_check setAction:@selector(onCellBtnClicked:)];

    if ([tableColumn.identifier isEqualToString:@"VideoColumnID"]) {
        NSString *itemTitle = nil;
        NSString *itemDetail = nil;
        NSString *imageURLString = nil;
        id result = [list_video objectAtIndex:row];
        if ([result isKindOfClass:[GTLYouTubeVideo class]]) {
            GTLYouTubeVideo *videoResult = (GTLYouTubeVideo *)result;
            itemTitle = videoResult.snippet.title;
            itemDetail = videoResult.snippet.descriptionProperty;
            imageURLString = videoResult.snippet.thumbnails.defaultProperty.url;
        } else if ([result isKindOfClass:[GTLYouTubePlaylistItem class]]) {
            GTLYouTubePlaylistItem *playlistResult = (GTLYouTubePlaylistItem *)result;
            itemTitle = playlistResult.snippet.title;
            itemDetail = playlistResult.snippet.descriptionProperty;
            imageURLString = playlistResult.snippet.thumbnails.defaultProperty.url;
        } else {
            // TODO: handle unexpected result object
        }

        NSNumber *select = [list_video_select objectAtIndex:row];
        NSNumber *progress = [list_video_downloadProgress objectAtIndex:row];

        cellView.lbl_title.stringValue = [NSString stringWithFormat:@"%@", itemTitle];
        cellView.lbl_subtitle.stringValue = [NSString stringWithFormat:@"%@", itemDetail];
        cellView.lbl_progress.stringValue = [NSString stringWithFormat:@"%d %%", [progress intValue]];

        if ([select boolValue]) {
            [cellView.btn_check setState:NSOnState];
        } else {
            [cellView.btn_check setState:NSOffState];
        }

        if (imageURLString) {
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            if (imageURL) {
                BOOL isLoading = NO;
                NSImage *image = [[Util sharedUtil] cachedImageAtURL:imageURL withPlacementImageName:nil isLoading:&isLoading];
                if (image !=nil) {
                    cellView.img.image = image;
                } else {
                    cellView.img.image = nil;
                }
            }
        }

        return cellView;
    }

    return cellView;
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
//    NSInteger selectedRow = [self.list_view selectedRow];
//    [self showServiceInfoAtIndex:(int)selectedRow];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj
{
    if ([obj object] == self.txt_url) {
        [self updateUI];
    }
}

@end
