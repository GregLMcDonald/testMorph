//
//  TMFFrameView.m
//  testMorph
//
//  Created by Greg on 2014-09-16.
//  Copyright (c) 2014 Tasty Morsels. All rights reserved.
//

#import "TMFFrameView.h"

#define kNUMBER_OF_POINTS 8
#define kLINE_WIDTH 1.0
#define kCIRCLE_RADIUS 50

#define kFRAME_WIDTH 256
#define kFRAME_HEIGHT 256
#define kFRAME_RATE 50

#define kNUMBER_OF_FRAMES 400

#define kMAX_MVMT_OUT 1.0
#define kMAX_MVMT_IN 0.5




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
    
    
    //But I have something more mathematical in mind...
    
    //Build morphing timeline: one entry per frame, one value per point at each frame
    //     All values initialized to 0.0
    //     zero means leave the point at its initial location
    //     +1 means the point is at its maximum distance outward from the initial location
    //     -1 is the furthest toward the center the point can move

    NSMutableArray *timeline = [[NSMutableArray alloc]init];
    
    for (int i=0; i < kNUMBER_OF_FRAMES; i++){
        NSMutableArray *pointValues = [ [NSMutableArray alloc] init];
        for (int j = 0; j < kNUMBER_OF_POINTS; j++){
            [pointValues addObject:[NSNumber numberWithFloat:0.0]];
        }
        [timeline addObject:pointValues];
    }
    
    int lastFrameTouched[kNUMBER_OF_POINTS];
    for (int i=0; i<kNUMBER_OF_POINTS; i++){
        lastFrameTouched[i] = -1;
    }
    
    
    struct animEvent {
        int point;
        int startFrame;
        int duration;
        float targetVal;
    };
    
    
    struct animEvent event[20];
    int numberOfEvents = 0;
    int evtNb = 0;
    
    
    event[evtNb].point = 0;
    event[evtNb].startFrame = 0;
    event[evtNb].duration = 50;
    event[evtNb].targetVal = 1.0;
    
    evtNb += 1;
    event[evtNb].point = 0;
    event[evtNb].startFrame = -1;
    event[evtNb].duration = 50;
    event[evtNb].targetVal = 0.0;
    
    evtNb += 1;
    event[evtNb].point = 0;
    event[evtNb].startFrame = -1;
    event[evtNb].duration = 50;
    event[evtNb].targetVal = 0.5;
    
    evtNb += 1;
    event[evtNb].point = 0;
    event[evtNb].startFrame = -1;
    event[evtNb].duration = 45;
    event[evtNb].targetVal = 0.0;
    
    
    evtNb += 1;
    event[evtNb].point = 3;
    event[evtNb].startFrame = -1;
    event[evtNb].duration = 100;
    event[evtNb].targetVal = 0.2;
    
    evtNb += 1;
    event[evtNb].point = 3;
    event[evtNb].startFrame = -1;
    event[evtNb].duration = 75;
    event[evtNb].targetVal = 0.0;
    
    
    evtNb += 1;
    event[evtNb].point = 5;
    event[evtNb].startFrame = -1;
    event[evtNb].duration = 50;
    event[evtNb].targetVal = 0.7;
    
    evtNb += 1;
    event[evtNb].point = 5;
    event[evtNb].startFrame = -1;
    event[evtNb].duration = 100;
    event[evtNb].targetVal = 0.0;

    
    evtNb += 1;
    event[evtNb].point = 7;
    event[evtNb].startFrame = -1;
    event[evtNb].duration = 80;
    event[evtNb].targetVal = 0.4;
    
    evtNb += 1;
    event[evtNb].point = 7;
    event[evtNb].startFrame = -1;
    event[evtNb].duration = 50;
    event[evtNb].targetVal = 0.0;
    
    
    
    numberOfEvents = evtNb + 1;
    
    //Set timeline values based on event specifications
    for (int i=0; i < numberOfEvents; i++){
        
        BOOL processEvent = YES;
        
        int thePoint = 0;
        int startFrame = 0;
        int endFrame = 0;
        
        if ( event[i].point >=0 && event[i].point < kNUMBER_OF_POINTS){
            thePoint = event[i].point;
        } else {
            NSLog(@"Not a valid point number in event %i.  Skipping event.", i);
            processEvent = NO;
        }
        
        if (processEvent){
            
            
            if (event[i].startFrame == -1){
                startFrame = lastFrameTouched[thePoint] + 1;
            } else {
                if ( event[i].startFrame > lastFrameTouched[thePoint]){
                    startFrame = event[i].startFrame;
                } else {
                    NSLog(@"Start frame in event %i overlaps last frame touched.  Skipping event.", i);
                    processEvent = NO;
                }
            }
            
            
            if (processEvent){
                endFrame = startFrame + event[i].duration - 1;
                if (endFrame >= kNUMBER_OF_FRAMES){
                    NSLog(@"Duration too long in event %i.  Skipping event.",i);
                    processEvent = NO;
                }
                
                
                if (processEvent){
                    
                    float initValue = 0.0;
                    float endValue = event[i].targetVal;
                    float delta = 0.0;
                    
                    if (lastFrameTouched[thePoint] == -1){
                        initValue = 0.0;
                    } else {
                        NSArray *values = timeline[lastFrameTouched[thePoint]];
                        initValue = [values[thePoint] floatValue];
                    }
                    
                    delta = (endValue - initValue) / event[i].duration ;
                    
                    float frameValue = initValue;
                    for ( int frameNb = startFrame; frameNb <= endFrame; frameNb++){
                        frameValue += delta;
                        NSMutableArray *values = timeline[frameNb];
                        [values replaceObjectAtIndex:thePoint withObject:[NSNumber numberWithFloat:frameValue]];
                        [timeline replaceObjectAtIndex:frameNb withObject:values];
                    }
                    lastFrameTouched[thePoint] = endFrame;
                    
                    
                    
                    for (int frameNb = endFrame+1 ; frameNb < kNUMBER_OF_FRAMES; frameNb++){
                        NSMutableArray *values = timeline[frameNb];
                        [values replaceObjectAtIndex:thePoint withObject:[NSNumber numberWithFloat:frameValue]];
                        [timeline replaceObjectAtIndex:frameNb withObject:values];
                        
                    }
                    
                }
            }
        }
    }
    
    
    
    for (int i = 0; i < kNUMBER_OF_FRAMES; i++){
        NSMutableArray *values = timeline[i];
        NSLog(@"%i:  %f  %f  %f  %f", i, [ values[0] floatValue], [ values[1] floatValue], [values[2] floatValue], [values[3] floatValue]);
    }
    
    
    
    
    
    
    float x_offset = kFRAME_WIDTH / 2.0;
    float y_offset = kFRAME_HEIGHT / 2.0;
    
    
    struct BezPoint {
        NSPoint p;
        NSPoint c1;
        NSPoint c2;
    };
    
    
    struct BezPoint points[ kNUMBER_OF_POINTS ];
    
    struct BezPoint fixedPoints[ kNUMBER_OF_POINTS];
    
    
    
    
    //Another way is to draw the frames using paths
    for (int i=0; i<kNUMBER_OF_FRAMES; i++){
 
        NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(kFRAME_WIDTH, kFRAME_HEIGHT)];
        [self.frames addObject:image];
        [image lockFocus];
        
        int indexForTimeline = i;
        if (i > 200){
            indexForTimeline = i - 201;
            
        }
        
        
        
        //Make points for reference circle (if we need it)
        fixedPoints[0].p = NSMakePoint(kCIRCLE_RADIUS, 0.0);
        fixedPoints[0].c1 = NSMakePoint(kCIRCLE_RADIUS, kCIRCLE_RADIUS * 0.55228);
        fixedPoints[0].c2 = NSMakePoint(kCIRCLE_RADIUS, -1 * kCIRCLE_RADIUS * 0.55228);
        for (int j=1; j < 4; j++){
            NSAffineTransform *rot = [NSAffineTransform transform];
            [rot rotateByDegrees:j*90.0];
            fixedPoints[j].p = [rot transformPoint:fixedPoints[0].p];
            fixedPoints[j].c1 = [rot transformPoint:fixedPoints[0].c1];
            fixedPoints[j].c2 = [rot transformPoint:fixedPoints[0].c2];
        }
        
    
        
        //Make the set of points for this frame
        points[0].p = NSMakePoint(kCIRCLE_RADIUS, 0.0);
        points[0].c1 = NSMakePoint(kCIRCLE_RADIUS, kCIRCLE_RADIUS * 4 * 0.55228 / kNUMBER_OF_POINTS);
        points[0].c2 = NSMakePoint(kCIRCLE_RADIUS, -1 * kCIRCLE_RADIUS * 4 * 0.55228 / kNUMBER_OF_POINTS);
        for (int j=1; j<kNUMBER_OF_POINTS; j++){
            NSAffineTransform *aRotation = [NSAffineTransform transform];
            [aRotation rotateByDegrees: j * 360.0 / kNUMBER_OF_POINTS];
            points[j].p = [aRotation transformPoint:points[0].p];
            points[j].c1 = [aRotation transformPoint:points[0].c1];
            points[j].c2 = [aRotation transformPoint:points[0].c2];
        }

        if (i > 200){
            //rotate the set of points by 25 degrees
            for (int j=0; j<kNUMBER_OF_POINTS; j++){
                NSAffineTransform *aRotation = [NSAffineTransform transform];
                [aRotation rotateByDegrees:25.0];
                points[j].p = [aRotation transformPoint:points[j].p];
                points[j].c1 = [aRotation transformPoint:points[j].c1];
                points[j].c2 = [aRotation transformPoint:points[j].c2];
            }
        }
        
        
        struct BezPoint framePoints[ kNUMBER_OF_POINTS ];
        
        //Copy points --- don't need to do this since I am redefining the points in the animation loop, but I'm lazy :)
        for (int j=0; j < kNUMBER_OF_POINTS; j++){
            framePoints[j].p = points[j].p;
            framePoints[j].c1 = points[j].c1;
            framePoints[j].c2 = points[j].c2;
        }
        
        
        
        
        //------------------------------------------------------
        //Move points for animation accorting to mophing timeline values
        //------------------------------------------------------
        
        NSArray *values = timeline[indexForTimeline];
        for (int j=0; j < kNUMBER_OF_POINTS; j++){
            NSAffineTransform *animationTransformation = [NSAffineTransform transform];
            float val = [values[j] floatValue];
            float scalar = 1.0;
            if (val >= 0){
                scalar = 1.0 + val * kMAX_MVMT_OUT;
            } else {
                scalar = 1.0 + val * kMAX_MVMT_IN;
            }
            [animationTransformation scaleBy: scalar];
            framePoints[j].p = [animationTransformation transformPoint:framePoints[j].p];
            framePoints[j].c1 = [animationTransformation transformPoint:framePoints[j].c1];
            framePoints[j].c2 = [animationTransformation transformPoint:framePoints[j].c2];
        }
       
        
        
        
        
        
        
        
        
        
        
        //Translate all points to frame center
        NSAffineTransform *translateToFrameCenter = [NSAffineTransform transform];
        [translateToFrameCenter translateXBy:x_offset yBy:y_offset];
        for (int j = 0 ; j < kNUMBER_OF_POINTS; j++){
            framePoints[j].p = [translateToFrameCenter transformPoint:framePoints[j].p];
            framePoints[j].c1 = [translateToFrameCenter transformPoint:framePoints[j].c1];
            framePoints[j].c2 = [translateToFrameCenter transformPoint:framePoints[j].c2];
            
            if (j<4){
            fixedPoints[j].p = [translateToFrameCenter transformPoint:fixedPoints[j].p];
            fixedPoints[j].c1 = [translateToFrameCenter transformPoint:fixedPoints[j].c1];
            fixedPoints[j].c2 = [translateToFrameCenter transformPoint:fixedPoints[j].c2];
            }
            
        }
        
        //Build path of reference circle
        NSBezierPath *refPath = [[NSBezierPath alloc] init];
        [refPath moveToPoint:fixedPoints[0].p];
        for (int j=1; j<4; j++){
            [refPath curveToPoint:fixedPoints[j].p
                  controlPoint1:fixedPoints[j-1].c1
                  controlPoint2:fixedPoints[j].c2];
        }
        [refPath curveToPoint:fixedPoints[0].p controlPoint1:fixedPoints[3].c1 controlPoint2:fixedPoints[0].c2];
        [refPath closePath];
        
        //Draw reference circle into current frame
        [[NSColor whiteColor] set];
        [refPath fill];
        [[NSColor blackColor] set];
        [refPath setLineWidth:1.0];
        [refPath stroke];

        
        

        //Build path of animated shape
        NSBezierPath *aPath = [[NSBezierPath alloc] init];
        [aPath moveToPoint:framePoints[0].p];
        for (int j=1; j<kNUMBER_OF_POINTS; j++){
            [aPath curveToPoint:framePoints[j].p
                  controlPoint1:framePoints[j-1].c1
                  controlPoint2:framePoints[j].c2];
        }
        [aPath curveToPoint:framePoints[0].p controlPoint1:framePoints[kNUMBER_OF_POINTS-1].c1 controlPoint2:framePoints[0].c2];
        [aPath closePath];

        //Draw animated shape into current frame
        [[[NSColor whiteColor] highlightWithLevel:0.9] set];
        [[NSColor colorWithRed:1.0 green:0 blue:0 alpha:0.3] set];
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
