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

#define kBaseWidth 3*kScale
#define kMaxHeight 100*kScale




#define kFRAME_WIDTH (kBaseWidth + 4)
#define kFRAME_HEIGHT (kMaxHeight + 4)

#define kNUMBER_OF_FRAMES 30



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
    
    
    float x_offset = kFRAME_WIDTH / 2.0;
    float y_offset = kFRAME_HEIGHT / 2.0;
    
    
    struct BezPoint {
        NSPoint p;
        NSPoint c1;
        NSPoint c2;
    };
    
    
    struct BezPoint points[ kNUMBER_OF_POINTS ];
    
    for (int i=0; i<kNUMBER_OF_FRAMES; i++){
 
        NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(kFRAME_WIDTH, kFRAME_HEIGHT)];
        [self.frames addObject:image];
        [image lockFocus];
        
        double frameFactor = (double)i/(kNUMBER_OF_FRAMES-1);
        
        //Make the set of points for this frame
        
       
        
        //c1 points at next point
        //c2 points back to previous point
        
        
        //uppermost
        double y = frameFactor * kMaxHeight;
        points[1].p = NSMakePoint(0, y);
        points[1].c2 = NSMakePoint(0, 0.8*y);
        points[1].c1 = NSMakePoint(0, 0.8*y);
        
        //leftmost
        points[0].p = NSMakePoint(-kBaseWidth/2.0,0);
        points[0].c2 = NSMakePoint(0,0);
        points[0].c1 = NSMakePoint(0,0.2*y); //toward uppermost
    
        //rightmost
        points[2].p = NSMakePoint(kBaseWidth/2.0, 0);
        points[2].c2 = NSMakePoint(0, 0.2*y ); //toward uppermost
        points[2].c1 = NSMakePoint(0, 0);
        
        
        //Translate all points to frame center
        NSAffineTransform *translateToFrameCenter = [NSAffineTransform transform];
        [translateToFrameCenter translateXBy:x_offset yBy:y_offset];
        for (int j = 0 ; j < kNUMBER_OF_POINTS; j++){
            points[j].p = [translateToFrameCenter transformPoint:points[j].p];
            points[j].c1 = [translateToFrameCenter transformPoint:points[j].c1];
            points[j].c2 = [translateToFrameCenter transformPoint:points[j].c2];
        }
        
        

        //Build path of animated shape
        NSBezierPath *aPath = [[NSBezierPath alloc] init];
        [aPath moveToPoint:points[0].p];
        for (int j=1; j<kNUMBER_OF_POINTS; j++){
            [aPath curveToPoint:points[j].p
                  controlPoint1:points[j-1].c1
                  controlPoint2:points[j].c2];
        }
        [aPath curveToPoint:points[0].p controlPoint1:points[kNUMBER_OF_POINTS-1].c1 controlPoint2:points[0].c2];
        [aPath closePath];

        //Draw animated shape into current frame
        [[NSColor whiteColor] set];
        [aPath fill];
        
        [[NSColor blackColor] set];
        [aPath setLineWidth:kLineWidth];
        [aPath stroke];
        
        [image unlockFocus];
    }
    
    
    //Write frames out to PNG files

    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *deskDir;
    
    deskDir = [dirPaths objectAtIndex:0];
    
    for (int i=0; i < [self.frames count]; i++){
        
        NSString *imageName = [NSString stringWithFormat:@"%@%04d%@", @"/temp_image/ballStarPoint", i, @"@2x.png"];
        
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
