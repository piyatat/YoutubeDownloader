//
//  AppDelegate.h
//  YoutubeDownloader
//
//  Created by Tei on 9/6/14.
//  Copyright (c) 2014 B2HOME. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MainViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, assign, readwrite) IBOutlet NSWindow          *window;
@property (nonatomic, retain, readwrite) MainViewController         *mainVC;

@end
