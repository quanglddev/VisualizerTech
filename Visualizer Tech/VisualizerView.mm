//
//  VisualizerView.m
//  iPodVisualizer
//
//  Created by Xinrong Guo on 13-3-30.
//  Copyright (c) 2013 Xinrong Guo. All rights reserved.
//

#import "VisualizerView.h"
#import <QuartzCore/QuartzCore.h>
#import "MeterTable.h"
#import <ChameleonFramework/Chameleon.h>

@implementation VisualizerView {
  CAEmitterLayer *emitterLayer;
  MeterTable meterTable;
}

+ (Class)layerClass {
  return [CAEmitterLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setBackgroundColor:[UIColor blackColor]];
    emitterLayer = (CAEmitterLayer *)self.layer;
    
    CGFloat width = MAX(frame.size.width, frame.size.height);
    CGFloat height = MIN(frame.size.width, frame.size.height);
    emitterLayer.emitterPosition = CGPointMake(width/2, height/2);
    emitterLayer.emitterSize = CGSizeMake(width-80, 60);
    emitterLayer.emitterShape = kCAEmitterLayerRectangle;
    emitterLayer.renderMode = kCAEmitterLayerAdditive;
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.name = @"cell";
    
    CAEmitterCell *childCell = [CAEmitterCell emitterCell];
    childCell.name = @"childCell";
    childCell.lifetime = 1.0f / 60.0f;
    childCell.birthRate = 60.0f;
    childCell.velocity = 0.0f;
    
    childCell.contents = (id)[[UIImage imageNamed:@"particleTexture.png"] CGImage];
    
    cell.emitterCells = @[childCell];
    
    //cell.color = [[UIColor colorWithRed:1.0f green:0.53f blue:0.0f alpha:0.8f] CGColor];
    cell.color = [RandomFlatColor CGColor];
    cell.redRange = 1.0f;
    cell.greenRange = 1.0f;
    cell.blueRange = 1.0f;
    cell.alphaRange = 1.0f;
    
    cell.redSpeed = 1.0f;
    cell.greenSpeed = 1.0f;
    cell.blueSpeed = 1.0f;
    cell.alphaSpeed = 1.0f;
    
    cell.scale = 0.2f;
    cell.scaleRange = 0.1f;
    
    cell.lifetime = 1.0f;
    cell.lifetimeRange = 1.0f;
    cell.birthRate = 80;
    
    cell.velocity = 10.0f;
    cell.velocityRange = 300.0f;
    cell.emissionRange = M_PI * 2;
    
    emitterLayer.emitterCells = @[cell];

    CADisplayLink *dpLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [dpLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
  }
  return self;
}

- (void)update
{
  float scale = 0.1;
  if (_audioPlayer.playing )
  {
    [_audioPlayer updateMeters];
    
    float power = 0.0f;
    for (int i = 0; i < [_audioPlayer numberOfChannels]; i++) {
      power += [_audioPlayer averagePowerForChannel:i];
    }
    power /= [_audioPlayer numberOfChannels];
    
    float level = meterTable.ValueAt(power);
    scale = level * 5;
  }
 
  [emitterLayer setValue:@(scale) forKeyPath:@"emitterCells.cell.emitterCells.childCell.scale"];
}

@end
