//
//  TMFFrameView.m
//  testMorph
//
//  Created by Greg on 2014-09-16.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import "TMFFrameView.h"

@interface TMFFrameView ()
@property BOOL iMayUseThis; //...or not!
@end

@implementation TMFFrameView

- (id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self){
        _iMayUseThis = YES;
        _frameRate = 50;
        _frames = [[NSMutableArray alloc] init];
        
        [self createFrames];
      
    }
    return self;
    
}

    
- (void)createFrames{
    
    
    //This is one way to get a set of frames: read them in from image files
    
    // NSImage* anImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IMG_6280" ofType:@"jpg"]];
    //[self.frames addObject:anImage];
    
    NSMutableArray* points = [[NSMutableArray alloc] init];
    
    
    
    
    //Another way is to draw the frames using paths
    for (int i=0; i<101; i++){
        NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(300, 300)];
        [self.frames addObject:image];
        [image lockFocus];
        NSBezierPath *aPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(10, 10, 20+2*i, 20+2*i)];
        [[NSColor redColor] set];
        [aPath setLineWidth:10.0];
        [aPath stroke];
        [image unlockFocus];
    }
}


- (void) drawRect:(NSRect)rect {
    
    
    
    //NSRect	bounds = [self bounds];
    //CGFloat emptySpace = 20;
    //CGFloat width = bounds.size.width - emptySpace;
    //CGFloat height = bounds.size.height - emptySpace;
    
    

    
    
    NSGraphicsContext *aContext = [NSGraphicsContext currentContext];
    

    
    [aContext saveGraphicsState];
    [aContext setShouldAntialias:YES];

    [NSGraphicsContext setCurrentContext:aContext];
    
    if (self.frameRate >= 0 && self.frameRate < [self.frames count]){
    [(NSImage *)[self.frames objectAtIndex:self.frameRate] drawInRect:rect];
    }
    /*
    if ( self.frameRate >= 50 ){
        
        [[NSColor yellowColor] set];
        NSRectFill(rect);
        if ([self.frames count] != 0){
            NSImage *anImage = [self.frames objectAtIndex:1];
            [anImage drawInRect:rect];
        }
        
    } else {
        
        if ([self.frames count] != 0){
            NSImage *anImage = [self.frames objectAtIndex:0];
            [anImage drawInRect:rect];
        }
    }
     */
    
    
    /*
    
    if (width > 10 && height > 0){
        
        NSBezierPath *aPath = [NSBezierPath bezierPathWithOvalInRect:
                               NSMakeRect(emptySpace/2.0, emptySpace/2.0, width, height)];
       [[NSColor redColor] set];
        [aPath fill];
        [[NSColor whiteColor] set];
        [aPath setLineWidth:5.0];
        [aPath stroke];
    }
*/
    

    
    [aContext restoreGraphicsState];
}

@end
