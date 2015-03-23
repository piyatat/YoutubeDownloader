//
//  MainViewController.h
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
