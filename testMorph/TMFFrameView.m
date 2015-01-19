//
//  TMFFrameView.m
//  testMorph
//
//  Created by Greg on 2014-09-16.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import "TMFFrameView.h"
#import <ImageIO/ImageIO.h>

#define kNUMBER_OF_POINTS 5

#define kGeyserWidth 60.0
#define kGeyserDip 5.0
#define kGeyserRestingRise 15.0
#define kGeyserRestingPore 5.0 //pore width
#define kGeyserOpenPore 40.0 //pore width when ball about to pop out
#define kGeyserOpenHeight 30.0


#define kFRAME_WIDTH 128
#define kFRAME_HEIGHT 128

#define kNUMBER_OF_FRAMES 16



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
    
    
    
    
    //Another way is to draw the frames using paths
    for (int i=0; i<kNUMBER_OF_FRAMES; i++){
 
        NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(kFRAME_WIDTH, kFRAME_HEIGHT)];
        [self.frames addObject:image];
        [image lockFocus];
        
        
        //Make the set of points for this frame
        
        int a = 15;
        int b = 5;
       
        //control point c1 is closer to next point
        
        
        //leftmost
        points[0].p = NSMakePoint(- kGeyserWidth/2.0, 0);
       // points[0].c2= NSMakePoint(- kGeyserWidth/2.0 + a, kGeyserRestingRise); //toward left of pore
        
        double p0_c2_offset = 15 - i * 10.0 / (kNUMBER_OF_FRAMES - 1);
        points[0].c2 = NSMakePoint(-kGeyserWidth/2.0 + p0_c2_offset, kGeyserRestingRise);
        points[0].c1 = NSMakePoint(- kGeyserWidth/2.0 + a, -kGeyserDip); //toward bottom
    
        //bottommost
        points[1].p = NSMakePoint(0, -kGeyserDip);
        points[1].c2 = NSMakePoint(-b, -kGeyserDip);
        points[1].c1 = NSMakePoint(+b, -kGeyserDip);
        
        
        //rightmost
        points[2].p = NSMakePoint(kGeyserWidth/2.0, 0);
        points[2].c2 = NSMakePoint(kGeyserWidth/2.0 - a, -kGeyserDip);
        points[2].c1 = NSMakePoint(kGeyserWidth/2.0 - p0_c2_offset, kGeyserRestingRise); //toward right of pore
        
        //right of pore
        
        double p3_y = kGeyserRestingRise + i * (kGeyserOpenHeight - kGeyserRestingRise)/(kNUMBER_OF_FRAMES -1);
        double p3_x = kGeyserRestingPore/2.0 + i * 0.5 * (kGeyserOpenPore - kGeyserRestingPore)/(kNUMBER_OF_FRAMES-1);
        
        points[3].p = NSMakePoint(p3_x,p3_y);
      //  points[3].c2 = NSMakePoint(kGeyserRestingPore/2.0 + b, kGeyserRestingRise); //close to rightmost
        points[3].c2 = NSMakePoint(p3_x, kGeyserRestingRise);
        points[3].c1 = NSMakePoint(0, 0.9*p3_y); //closer to left of pore point
        
        //left of pore
       
        points[4].p = NSMakePoint(-p3_x, p3_y);
        points[4].c2= NSMakePoint(0, 0.9*p3_y); //closer to right of pore point
      //  points[4].c1= NSMakePoint(-kGeyserRestingPore/2.0 - b, kGeyserRestingRise); //close to leftmost
        points[4].c1 = NSMakePoint(-p3_x, kGeyserRestingRise);
        
        
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
        [aPath setLineWidth:.5];
        [aPath stroke];
        
        [image unlockFocus];
    }
    
    
    //Write frames out to PNG files

    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *deskDir;
    
    deskDir = [dirPaths objectAtIndex:0];
    
    for (int i=0; i < [self.frames count]; i++){
        
        NSString *imageName = [NSString stringWithFormat:@"%@%04d%@", @"/temp_image/temp_", i, @".png"];
        
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
    [(NSImage *)[self.frames objectAtIndex:self.currentFrame] drawInRect:rect];
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
