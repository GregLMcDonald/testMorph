//
//  TMFFrameView.h
//  testMorph
//
//  Created by Greg on 2014-09-16.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMFFrameView : NSView

//@property int frameRate;
@property int currentFrame;
@property NSMutableArray* frames;
@property BOOL stopAnimation;





@end
