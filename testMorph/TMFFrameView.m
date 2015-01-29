//
//  TMFFrameView.m
//  testMorph
//
//  Created by Greg on 2014-09-16.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import "TMFFrameView.h"
#import <ImageIO/ImageIO.h>

#define kNUMBER_OF_POINTS 3

#define kScale 2.0
#define kLineWidth 1

#define kDiameter (150*kScale)
#define kOffset (2*kScale)



#define kFRAME_WIDTH (kDiameter + 2*kOffset)
#define kFRAME_HEIGHT kFRAME_WIDTH

#define kNUMBER_OF_FRAMES 60



@implementation TMFFrameView{
    int frameChange;
}



- (id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self){
        _currentFrame = 0;
        _frames = [[NSMutableArray alloc] init];
        
        [self createFrames];
        
        self->frameChange = 1;
        _stopAnimation = NO;
    }
    return self;
    
}

    
- (void)createFrames{
    

    
    for (int i=0; i<kNUMBER_OF_FRAMES; i++){
 
        NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(kFRAME_WIDTH, kFRAME_HEIGHT)];
        [self.frames addObject:image];
        [image lockFocus];
        
        double frameFactor = (double)i/(kNUMBER_OF_FRAMES - 1);
        
        //Draw a circle
        NSBezierPath *aPath = [NSBezierPath bezierPathWithOvalInRect:NSRectFromCGRect(CGRectMake(kOffset, kOffset, kDiameter, kDiameter))];
        
        NSPoint midPoint = NSPointFromCGPoint(CGPointMake(kFRAME_WIDTH/2.0, kFRAME_HEIGHT/2.0));
        NSPoint upPoint = NSPointFromCGPoint(CGPointMake(kFRAME_WIDTH/2.0, kFRAME_HEIGHT));
        
        double dist = 1.1*(kDiameter + kOffset);
        
        double theta = 90 - (frameFactor * 359);
        NSPoint anglePoint = NSPointFromCGPoint(CGPointMake(midPoint.x + dist*cos(theta), midPoint.y + dist*sin(theta)));
        
        NSBezierPath *clippingPath = [NSBezierPath new];
        [clippingPath moveToPoint:midPoint];
        [clippingPath lineToPoint:upPoint];
        [clippingPath appendBezierPathWithArcWithCenter:midPoint radius:dist startAngle:90 endAngle:theta clockwise:YES];
        [clippingPath lineToPoint:midPoint];
        
        [clippingPath addClip];
        
        
        //Clip out wedge
        
        
   //     [NSBezierPath clipRect:NSRectFromCGRect(CGRectMake(0, (1-frameFactor)*kDiameter, 2*kDiameter, 2*kDiameter))];
     //   [aPath addClip];
        
        [[NSColor whiteColor] set];
        [aPath fill];
        /*
         
        [[NSColor blackColor] set];
        [aPath setLineWidth:kLineWidth];
        [aPath stroke];
        */
        
        /*
        NSBezierPath* line = [NSBezierPath bezierPath];
        [line moveToPoint:NSPointFromCGPoint(CGPointMake(0, (1-frameFactor)*kDiameter))];
        [line lineToPoint:NSPointFromCGPoint(CGPointMake(2*kDiameter,  (1-frameFactor)*kDiameter))];
        [line setLineWidth:kLineWidth];
        [line stroke];
        */
        
        
         
         
        /*
        aPath = [NSBezierPath bezierPathWithOvalInRect:NSRectFromCGRect(CGRectMake(kDiameter/2.0, kDiameter/4.0, kDiameter/2.0, kDiameter/2.0))];
        [[NSColor blackColor] set];
        [aPath fill];
        
        [[NSColor blackColor] set];
        [aPath setLineWidth:kLineWidth];
        [aPath stroke];
        */
        
        
        
        [image unlockFocus];
    }
    
    
    //Write frames out to PNG files

    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *deskDir;
    
    deskDir = [dirPaths objectAtIndex:0];
    
    for (int i=0; i < [self.frames count]; i++){
        
     NSString *imageName = [NSString stringWithFormat:@"%@%04d%@", @"/temp_image/timer150_", i, @"@2x.png"];
        
///       NSString *imageName = @"/temp_image/ball60@1x.png";
        
        NSString *imagePath = [[NSString alloc] initWithString:[deskDir stringByAppendingPathComponent: imageName]];
        
        CGImageRef cgRef = [ (NSImage *)self.frames[i] CGImageForProposedRect:NULL context:nil hints:nil ];
        NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef ];
        [newRep setSize:[(NSImage *)self.frames[i] size]];
        NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
        [pngData writeToFile:imagePath atomically:YES];

    }
    
    
    
    
    
    
    /*
    - (void) writeCGImage: (CGImageRef) image toURL: (NSURL*) url withType: (CFStringRef) imageType andOptions: (CFDictionaryRef) options
    {
        CGImageDestinationRef myImageDest = CGImageDestinationCreateWithURL((CFURLRef)url, imageType, 1, nil);
        CGImageDestinationAddImage(myImageDest, image, options);
        CGImageDestinationFinalize(myImageDest);
        CFRelease(myImageDest);
    }
     
     
     + (void)saveImage:(NSImage *)image atPath:(NSString *)path {
     
     CGImageRef cgRef = [image CGImageForProposedRect:NULL
     context:nil
     hints:nil];
     NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
     [newRep setSize:[image size]];   // if you want the same resolution
     NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
     [pngData writeToFile:path atomically:YES];
     [newRep autorelease];
     }
     
     
     
     
    */
    
}


- (void) drawRect:(NSRect)rect {
    
    
    NSGraphicsContext *aContext = [NSGraphicsContext currentContext];
    

    
    [aContext saveGraphicsState];
    [aContext setShouldAntialias:YES];

    [NSGraphicsContext setCurrentContext:aContext];
    
    
    if (self.currentFrame >= 0 && self.currentFrame < [self.frames count]){
        NSImage* im = [self.frames objectAtIndex:self.currentFrame];
        CGRect imRect = CGRectMake(0, 0, im.size.width, im.size.height);
        [(NSImage *)[self.frames objectAtIndex:self.currentFrame] drawInRect:imRect];
    }
    
    
    if (self.currentFrame == [self.frames count] - 1) self->frameChange = -3;
    if (self.currentFrame == 0) self->frameChange = +1;
    
    self.currentFrame += self->frameChange;
    if (self.currentFrame <= 0){
        self.currentFrame = 0;
        self.stopAnimation = YES;
    }
    
    
    [aContext restoreGraphicsState];
}

@end
