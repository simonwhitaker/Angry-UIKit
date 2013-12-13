//
//  SWViewController.m
//  Angry UIKit
//
//  Created by Simon Whitaker on 10/12/2013.
//  Copyright (c) 2013 Simon Whitaker. All rights reserved.
//

#import "SWViewController.h"

@interface SWViewController () <UIDynamicAnimatorDelegate>
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic) CGPoint originalDynamicViewCenter;
@property (nonatomic, strong) NSArray *originalObstacleViewCenters;
@end

typedef NS_ENUM(NSUInteger, SWDemoStage) {
    SWDemoStageGravity,
    SWDemoStageGravityWithBoundary,
    SWDemoStageGravityWithBoundaryAndObstacles,
    SWDemoStageGravityWithBoundaryObstaclesAndPush,
    SWDemoStageGravityWithBoundaryObstaclesAndPushWithImages,
};

@implementation SWViewController

static SWDemoStage demoStage = SWDemoStageGravityWithBoundaryObstaclesAndPushWithImages;

- (void)viewDidLoad {
    if (demoStage >= SWDemoStageGravityWithBoundaryObstaclesAndPush) {
        self.dynamicView.center = CGPointMake(self.dynamicView.frame.size.width / 2, self.dynamicView.frame.size.height / 2);
    }
    else {
        self.dynamicView.center = CGPointMake(self.view.center.x, 150);
    }
    
    if (demoStage == SWDemoStageGravityWithBoundaryAndObstacles) {
        NSArray *obstaclesToDelete = [self.obstacleViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag > 0"]];
        self.obstacleViews = [self.obstacleViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == 0"]];
        [obstaclesToDelete makeObjectsPerformSelector:@selector(removeFromSuperview)];
        CGFloat centerOffset = ((UIView*)obstaclesToDelete[0]).frame.size.height / 2;
        [self.obstacleViews enumerateObjectsUsingBlock:^(UIView *obstacleView, NSUInteger idx, BOOL *stop) {
            obstacleView.center = CGPointMake(470, self.view.frame.size.width - (centerOffset + (centerOffset * 2 * idx)));
        }];
    }
    else if (demoStage <= SWDemoStageGravityWithBoundary) {
        [self.obstacleViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.obstacleViews = nil;
    }
    
    if (demoStage < SWDemoStageGravityWithBoundaryObstaclesAndPushWithImages) {
        for (UIView *view in [self.obstacleViews arrayByAddingObject:self.dynamicView]) {
            [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)handleTapGestureRecognizer:(UITapGestureRecognizer*)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.originalDynamicViewCenter = self.dynamicView.center;
        self.originalObstacleViewCenters = [self.obstacleViews valueForKeyPath:@"center"];
        self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        
        NSArray *allViews = [[NSArray arrayWithArray:self.obstacleViews] arrayByAddingObject:self.dynamicView];

        // Add the gravity behaviour
        UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:allViews];
        [self.dynamicAnimator addBehavior:gravityBehavior];
        
        // Add boundaries
        if (demoStage >= SWDemoStageGravityWithBoundary) {
            UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:allViews];
            collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
            [self.dynamicAnimator addBehavior:collisionBehavior];
        }
        else {
            gravityBehavior.action = ^{
                if (!CGRectIntersectsRect(self.view.frame, self.dynamicView.frame)) {
                    [self SW_reset];
                }
            };
        }
        
        // Give the main view a kick
        if (demoStage >= SWDemoStageGravityWithBoundaryObstaclesAndPush) {
            UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.dynamicView] mode:UIPushBehaviorModeInstantaneous];
            pushBehavior.magnitude = 15.0;
            pushBehavior.angle = -0.4;
            [self.dynamicAnimator addBehavior:pushBehavior];
        }
        
        self.dynamicAnimator.delegate = self;
    }
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    [self SW_reset];
}

- (void)SW_reset {
    [self.dynamicAnimator removeAllBehaviors];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.dynamicView.center = self.originalDynamicViewCenter;
        [self.obstacleViews enumerateObjectsUsingBlock:^(UIView *obstacleView, NSUInteger idx, BOOL *stop) {
            obstacleView.center = [self.originalObstacleViewCenters[idx] CGPointValue];
        }];
    });
}

@end
