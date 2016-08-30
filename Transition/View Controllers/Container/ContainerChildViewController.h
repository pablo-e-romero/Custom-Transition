//
//  ContainerChildViewController.h
//  Transition
//
//  Created by Pablo Romero on 8/27/16.
//  Copyright © 2016 Pablo Romero. All rights reserved.
//

#import "ContainerViewController.h"

@interface ContainerChildViewController : UIViewController

@property(nonatomic, weak) ContainerViewController *containerViewController;

- (void)updateInteractiveTransition:(CGFloat)progress;
- (void)cancelInteractiveTransition;
- (void)finishInteractiveTransition;

@end
