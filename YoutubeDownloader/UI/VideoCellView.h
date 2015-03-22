//
//  VideoCellView.h
//  YoutubeDownloader
//
//  Created by Tei on 9/6/14.
//  Copyright (c) 2014 B2HOME. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VideoCellView : NSTableCellView

@property (nonatomic, strong, readwrite) IBOutlet NSButton          *btn_check;
@property (nonatomic, strong, readwrite) IBOutlet NSImageView       *img;
@property (nonatomic, strong, readwrite) IBOutlet NSTextField       *lbl_title;
@property (nonatomic, strong, readwrite) IBOutlet NSTextField       *lbl_subtitle;
@property (nonatomic, strong, readwrite) IBOutlet NSTextField       *lbl_progress;

@end
