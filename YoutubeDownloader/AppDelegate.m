//
//  AppDelegate.m
//  YoutubeDownloader
//
//  Created by Tei on 9/6/14.
//  Copyright (c) 2014 B2HOME. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainVC = [[MainViewController alloc] init];
    
    self.mainVC.view.frame = ((NSView *)self.window.contentView).bounds;
    [self.window.contentView addSubview:self.mainVC.view];
}

@end
