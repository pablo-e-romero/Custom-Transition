//
//  ContainerViewController.h
//  Transition
//
//  Created by Pablo Romero on 8/27/16.
//  Copyright © 2016 Pablo Romero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerViewController : UIViewController

@property(nonatomic, assign) CGFloat transitionAnimationDuration;
@property(nonatomic, assign, getter=isOverViewVisible, readonly) BOOL overViewVisible;
@property(nonatomic, assign, getter=isInteractionInProgress, readonly) BOOL interactionInProgress;

- (void)dismissOverViewController;
- (void)presentOverViewController;

@end
