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
@end

@implementation SWViewController

- (IBAction)handleTapGestureRecognizer:(UITapGestureRecognizer*)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.originalDynamicViewCenter = self.dynamicView.center;
        self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        
        // Add the gravity behaviour
        UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.dynamicView]];
        gravityBehavior.action = ^{
            if (!CGRectIntersectsRect(self.view.frame, self.dynamicView.frame)) {
            }
        };
        
        // Add boundaries
        UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.dynamicView]];
        collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
        
        [self.dynamicAnimator addBehavior:collisionBehavior];
        [self.dynamicAnimator addBehavior:gravityBehavior];
        self.dynamicAnimator.delegate = self;
    }
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    [self.dynamicAnimator removeAllBehaviors];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.dynamicView.center = self.originalDynamicViewCenter;
    });
}

@end
