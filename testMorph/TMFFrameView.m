//
//  TMFFrameView.m
//  testMorph
//
//  Created by Greg on 2014-09-16.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import "TMFFrameView.h"

#define kNUMBER_OF_POINTS 4
#define kLINE_WIDTH 1.0
#define kCIRCLE_RADIUS 100

#define kFRAME_WIDTH 256
#define kFRAME_HEIGHT 256
#define kFRAME_RATE 50

@interface TMFFrameView ()
@property BOOL iMayUseThis; //...or not!
@end

@implementation TMFFrameView

- (id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self){
        _iMayUseThis = YES;
        
        _frameRate = kFRAME_RATE;
        
        _frames = [[NSMutableArray alloc] init];
        
        [self createFrames];
      
    }
    return self;
    
}

    
- (void)createFrames{
    
    
    //This is one way to get a set of frames: read them in from image files
    
    // NSImage* anImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IMG_6280" ofType:@"jpg"]];
    //[self.frames addObject:anImage];
    
    
    //Make sets of points that yield circle when rendered at set of cubic bezier curves
    float p_init_x[kNUMBER_OF_POINTS];
    float p_init_y[kNUMBER_OF_POINTS];
    
    float p_c1_x[kNUMBER_OF_POINTS];
    float p_c1_y[kNUMBER_OF_POINTS];
    
    float p_c2_x[kNUMBER_OF_POINTS];
    float p_c2_y[kNUMBER_OF_POINTS];
    
    float p_final_x[kNUMBER_OF_POINTS];
    float p_final_y[kNUMBER_OF_POINTS];
    
    float x_offset = kFRAME_WIDTH / 2.0;
    float y_offset = kFRAME_HEIGHT / 2.0;
    
    
    p_init_x[0] = kCIRCLE_RADIUS *  1.0;
    p_init_y[0] = kCIRCLE_RADIUS *  0.0;
    
    p_c1_x[0] = kCIRCLE_RADIUS *  1.0;
    p_c1_y[0] = kCIRCLE_RADIUS *  0.55228;
    
    p_c2_x[0] = kCIRCLE_RADIUS *  0.55228;
    p_c2_y[0] = kCIRCLE_RADIUS *  1.0;
    
    p_final_x[0] = kCIRCLE_RADIUS *  0.0;
    p_final_y[0] = kCIRCLE_RADIUS *  1.0;
    
    
    p_init_x[1] = p_final_x[0];
    p_init_y[1] = p_final_y[0];
    
    p_c1_x[1] = p_c2_x[0] * -1;
    p_c1_y[1] = p_c2_y[0];
    
    p_c2_x[1] = p_c1_x[0] * -1;
    p_c2_y[1] = p_c1_y[0];
    
    p_final_x[1] = p_init_x[0] * -1;
    p_final_y[1] = p_init_y[0];

    
    p_init_x[2] = p_final_x[1];
    p_init_y[2] = p_final_y[1];
    
    p_c1_x[2] = p_c2_x[1];
    p_c1_y[2] = p_c2_y[1] * -1;
    
    p_c2_x[2] = p_c1_x[1];
    p_c2_y[2] = p_c1_y[1] * -1;
    
    p_final_x[2] = p_init_x[1];
    p_final_y[2] = p_init_y[1] * -1;

    
    p_init_x[3] = p_final_x[2];
    p_init_y[3] = p_final_y[2];
    
    p_c1_x[3] = p_c2_x[2] * -1;
    p_c1_y[3] = p_c2_y[2];
    
    p_c2_x[3] = p_c1_x[2] * -1;
    p_c2_y[3] = p_c1_y[2];
    
    p_final_x[3] = p_init_x[0];
    p_final_y[3] = p_init_y[0];
    
    
    
    
    for (int i = 0 ; i < 4; i++){
        p_init_x[i] = x_offset + p_init_x[i];
        p_init_y[i] = y_offset + p_init_y[i];
        p_final_x[i] = x_offset + p_final_x[i];
        p_final_y[i] = y_offset + p_final_y[i];
        p_c1_x[i] = x_offset + p_c1_x[i];
        p_c1_y[i] = y_offset + p_c1_y[i];
        p_c2_x[i] = x_offset + p_c2_x[i];
        p_c2_y[i] = y_offset + p_c2_y[i];
    }
    
    NSBezierPath *aPath = [[NSBezierPath alloc] init];
    [aPath moveToPoint:NSMakePoint(p_init_x[0], p_init_y[0])];
    for (int i=0; i<4; i++){
    [aPath curveToPoint:NSMakePoint(p_final_x[i], p_final_y[i])
          controlPoint1:NSMakePoint(p_c1_x[i], p_c1_y[i])
          controlPoint2:NSMakePoint(p_c2_x[i], p_c2_y[i])];
    }
    [aPath closePath];
    
    
    
    //Another way is to draw the frames using paths
    for (int i=0; i<101; i++){
        NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(kFRAME_WIDTH, kFRAME_HEIGHT)];
        [self.frames addObject:image];
        [image lockFocus];
        
        float temp_c1_x[4];
        float temp_c1_y[4];
        float temp_c2_x[4];
        float temp_c2_y[4];
        
        
        for (int j = 0 ; j < 4; j++){
            
            if ( j % 2 == 0){

            temp_c1_x[j] = (1.0 + i * 0.2 / 100) * p_c1_x[j];
            temp_c1_y[j] = (1.0 + i * 0.2 / 100) * p_c1_y[j];
            temp_c2_x[j] = (1.0 + i * 0.2 / 100) * p_c2_x[j];
            temp_c2_y[j] = (1.0 + i * 0.2 / 100) * p_c2_y[j];
 
            } else {
                
                temp_c1_x[j] = (1.0 + i * 0.2 / 100) * p_c1_x[j];
                temp_c1_y[j] = (1.0 + i * 0.2 / 100) * p_c1_y[j];
                temp_c2_x[j] = (1.0 + i * 0.2 / 100) * p_c2_x[j];
                temp_c2_y[j] = (1.0 + i * 0.2 / 100) * p_c2_y[j];
                
            }
        }

        
        NSBezierPath *aPath = [[NSBezierPath alloc] init];
        [aPath moveToPoint:NSMakePoint(p_init_x[0], p_init_y[0])];
        for (int i=0; i<4; i++){
            [aPath curveToPoint:NSMakePoint(p_final_x[i], p_final_y[i])
                  controlPoint1:NSMakePoint(temp_c1_x[i], temp_c1_y[i])
                  controlPoint2:NSMakePoint(temp_c2_x[i], temp_c2_y[i])];
        }
        [aPath closePath];

        
        [[[NSColor whiteColor] highlightWithLevel:0.9] set];
        [aPath fill];
        
        [[NSColor blackColor] set];
        [aPath setLineWidth:0.5];
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
