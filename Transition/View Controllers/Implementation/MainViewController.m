//
//  MainViewController.m
//  Transition
//
//  Created by Pablo Romero on 8/25/16.
//  Copyright © 2016 Pablo Romero. All rights reserved.
//

#import "MainViewController.h"

static CGFloat const kButtonsDisplacement = 30;

@interface MainViewController()

@property(nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property(nonatomic, weak) IBOutlet UIVisualEffectView *backgroundVisualEffectView;

@property(nonatomic, weak) IBOutlet UIButton *snapchatButton;
@property(nonatomic, weak) IBOutlet UIButton *groupsButton;
@property(nonatomic, weak) IBOutlet UIButton *dialogButton;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint *snapchatButtonTopConstraint;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *groupsButtonTrailingConstraint;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *dialogButtonLeadingConstraint;

@property(nonatomic, assign) CGFloat originalSnapchatButtonTopConstraintConstant;
@property(nonatomic, assign) CGFloat originalGroupsButtonTrailingConstraintConstant;
@property(nonatomic, assign) CGFloat originalDialogButtonLeadingConstraintConstant;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.originalSnapchatButtonTopConstraintConstant =
    self.snapchatButtonTopConstraint.constant;
  
    self.originalDialogButtonLeadingConstraintConstant =
    self.dialogButtonLeadingConstraint.constant;
  
    self.originalGroupsButtonTrailingConstraintConstant =
    self.groupsButtonTrailingConstraint.constant;
    
    self.dialogButton.layer.cornerRadius = self.dialogButton.frame.size.height / 2.0;
    self.groupsButton.layer.cornerRadius = self.groupsButton.frame.size.height / 2.0;
    
    self.backgroundVisualEffectView.alpha = 0;
}

#pragma mark - Buttons

- (void)updateBackgroundWithProgress:(CGFloat)progress
{
    CGFloat value = (self.containerViewController.isOverViewVisible ?
                     1 - fabs(progress):
                     progress);
    
    self.backgroundVisualEffectView.alpha = value;
}

- (void)updateButtonsAlphaWithProgress:(CGFloat)progress
{
    CGFloat value = (self.containerViewController.isOverViewVisible ?
                     fabs(fmin(0, progress + 0.5) * 2):
                     fmax(0, 1 - (progress * 2)));
    
    self.snapchatButton.alpha = value;
    self.dialogButton.alpha = value;
    self.groupsButton.alpha = value;
}

- (void)transformContentWithProgress:(CGFloat)progress
{
    CGFloat translationY = progress * self.view.frame.size.height;
    self.snapchatButton.transform = CGAffineTransformMakeTranslation(0, translationY);
    
    CGFloat buttonsTranslationX = progress * kButtonsDisplacement;
    self.groupsButton.transform = CGAffineTransformMakeTranslation(-buttonsTranslationX, 0);
    self.dialogButton.transform = CGAffineTransformMakeTranslation(buttonsTranslationX, 0);
}

#pragma mark - IBActions

- (IBAction)snapchatButtonTouched:(id)sender
{
    [self.containerViewController presentOverViewController];
}

#pragma mark - ContainerChildViewController

- (void)updateInteractiveTransition:(CGFloat)progress
{
    [self transformContentWithProgress:progress];
    [self updateButtonsAlphaWithProgress:progress];
    [self updateBackgroundWithProgress:progress];
}

- (void)cancelInteractiveTransition
{
    CGFloat progress = 0;
    
    __block typeof(self) blockSelf = self;
    
    void (^AnimationBlock)(void) = ^void (void)
    {
        blockSelf.snapchatButton.transform = CGAffineTransformIdentity;
        blockSelf.groupsButton.transform = CGAffineTransformIdentity;
        blockSelf.dialogButton.transform = CGAffineTransformIdentity;
        
        [blockSelf updateButtonsAlphaWithProgress:progress];
        [blockSelf updateBackgroundWithProgress:progress];
    };
    
    [UIView animateWithDuration:[self.containerViewController transitionAnimationDuration]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:AnimationBlock
                     completion:nil];
}

- (void)finishInteractiveTransition
{
    __block typeof(self) blockSelf = self;
   
    CGFloat progress = (self.containerViewController.isOverViewVisible ? -1 : 1);
    
    CGFloat newSnapchatButtonTopConstraintConstant =
    (self.containerViewController.isOverViewVisible ?
     self.originalSnapchatButtonTopConstraintConstant :
     self.view.frame.size.height +
     self.originalSnapchatButtonTopConstraintConstant);
    
    CGFloat newDialogButtonLeadingConstraintConstant =
    (self.containerViewController.isOverViewVisible ?
     self.originalDialogButtonLeadingConstraintConstant :
     kButtonsDisplacement +
     self.originalDialogButtonLeadingConstraintConstant);
    
    CGFloat newGroupsButtonTrailingConstraintConstant =
    (self.containerViewController.isOverViewVisible ?
     self.originalGroupsButtonTrailingConstraintConstant :
     kButtonsDisplacement +
     self.originalGroupsButtonTrailingConstraintConstant);
    
    void (^AnimationBlock)(void) = ^void (void)
    {
        [blockSelf transformContentWithProgress:progress];
        [blockSelf updateButtonsAlphaWithProgress:progress];
        [blockSelf updateBackgroundWithProgress:progress];
    };
    
    void (^CompletionBlock)(BOOL finished) = ^void (BOOL finished)
    {
        blockSelf.snapchatButtonTopConstraint.constant =
        newSnapchatButtonTopConstraintConstant;
        
        blockSelf.dialogButtonLeadingConstraint.constant =
        newDialogButtonLeadingConstraintConstant;
        
        blockSelf.groupsButtonTrailingConstraint.constant =
        newGroupsButtonTrailingConstraintConstant;
        
        blockSelf.snapchatButton.transform = CGAffineTransformIdentity;
        blockSelf.groupsButton.transform = CGAffineTransformIdentity;
        blockSelf.dialogButton.transform = CGAffineTransformIdentity;
        
        [blockSelf.view layoutIfNeeded];
    };
    
    [UIView animateWithDuration:[self.containerViewController transitionAnimationDuration]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:AnimationBlock
                     completion:CompletionBlock];
}

@end
