//
//  SWViewController.h
//  Angry UIKit
//
//  Created by Simon Whitaker on 10/12/2013.
//  Copyright (c) 2013 Simon Whitaker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *dynamicView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *obstacleViews;

@end
