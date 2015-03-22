//
//  MainViewController.h
//  YoutubeDownloader
//
//  Created by Tei on 9/6/14.
//  Copyright (c) 2014 B2HOME. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>
{
    BBItemType          itemType;
    BOOL                isDownloading;
    NSString            *directory;
    NSMutableArray      *list_video;
    NSMutableArray      *list_video_select;
    NSMutableArray      *list_video_downloadProgress;
    int                 downloadingVideoIndex;
}

@property (nonatomic, strong, readwrite) IBOutlet NSTableView       *list_view;

@property (nonatomic, strong, readwrite) IBOutlet NSView            *view_control;

@property (nonatomic, strong, readwrite) IBOutlet NSTextField           *txt_url;
@property (nonatomic, strong, readwrite) IBOutlet NSProgressIndicator   *loading_indicator;
@property (nonatomic, strong, readwrite) IBOutlet NSButton              *btn_fetch;

@property (nonatomic, strong, readwrite) IBOutlet NSButton              *btn_selectAll;
@property (nonatomic, strong, readwrite) IBOutlet NSButton              *btn_selectNone;
@property (nonatomic, strong, readwrite) IBOutlet NSButton              *btn_download;
@property (nonatomic, strong, readwrite) IBOutlet NSButton              *btn_stop;

@property (nonatomic, strong, readwrite) IBOutlet NSTextField           *txt_key;
@property (nonatomic, strong, readwrite) IBOutlet NSButton              *btn_key;

@end
