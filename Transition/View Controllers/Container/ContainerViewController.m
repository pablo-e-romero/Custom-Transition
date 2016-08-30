//
//  ContainerViewController.m
//  Transition
//
//  Created by Pablo Romero on 8/27/16.
//  Copyright © 2016 Pablo Romero. All rights reserved.
//

#import "ContainerViewController.h"

#import "ContainerChildViewController.h"

static CGFloat const kActionButtonDisplacement = 55.0;
static CGFloat const kActionButtonSmallSize = 50.0;

@interface ContainerViewController()

@property(nonatomic, strong) ContainerChildViewController *overViewController;
@property(nonatomic, strong) ContainerChildViewController *mainViewController;

@property(nonatomic, assign, getter=isOverViewVisible, readwrite) BOOL overViewVisible;
@property(nonatomic, assign, getter=isInteractionInProgress, readwrite) BOOL interactionInProgress;
@property(nonatomic, assign) BOOL shouldCompleteTransition;

@property(nonatomic, weak) IBOutlet UIView *overViewContainer;
@property(nonatomic, weak) IBOutlet UIView *mainViewContainer;

@property(nonatomic, weak) IBOutlet UIButton *actionButton;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint *overViewTopConstraint;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint *actionButtonBottomConstraint;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *actionButtonWidthConstraint;

@property(nonatomic, assign) CGFloat originalActionButtonBottomConstraintConstant;
@property(nonatomic, assign) CGFloat originalActionButtonWidthConstraintConstant;
@property(nonatomic, assign) CGFloat overViewTopEstimatedValue;



@end

@implementation ContainerViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.overViewVisible = NO;
    self.overViewTopEstimatedValue = -[UIScreen mainScreen].bounds.size.height;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addGestureRecogniserOnView:self.view];
    
    self.overViewTopConstraint.constant =
    -[UIScreen mainScreen].bounds.size.height;
    
    self.originalActionButtonBottomConstraintConstant =
    self.actionButtonBottomConstraint.constant;
    
    self.originalActionButtonWidthConstraintConstant =
    self.actionButtonWidthConstraint.constant;
}

- (BOOL)prefersStatusBarHidden
{
    static CGFloat const kVisibleStatusBarRange = -10.0;
    return (self.overViewTopEstimatedValue < kVisibleStatusBarRange);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedOver"])
    {
        ContainerChildViewController *viewController = segue.destinationViewController;
        viewController.containerViewController = self;
        self.overViewController = segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:@"embedMain"])
    {
        ContainerChildViewController *viewController = segue.destinationViewController;
        viewController.containerViewController = self;
        self.mainViewController = segue.destinationViewController;
    }
}

#pragma mark - Action button

- (IBAction)actionButtonTouched:(id)sender
{
    if (self.isOverViewVisible)
    {
        [self dismissOverViewController];
    }
}

- (void)transformContentWithProgress:(CGFloat)progress
{
    // Over view container - Make translation
    
    CGFloat translationY = progress * self.view.frame.size.height;
    self.overViewContainer.transform = CGAffineTransformMakeTranslation(0, translationY);
    self.overViewTopEstimatedValue = self.overViewTopConstraint.constant + translationY;
    
    // Action button - Make scale
    
    CGFloat value =
    (self.isOverViewVisible ?
     fabs(progress) :
     1.0 - progress);
    
    CGFloat newActionButtonSize =
    kActionButtonSmallSize + value *
    (self.originalActionButtonWidthConstraintConstant - kActionButtonSmallSize);
    
    CGFloat actionButtonScale = newActionButtonSize / self.actionButtonWidthConstraint.constant;
    
    CGAffineTransform actionButtonScaleTransform = CGAffineTransformMakeScale(actionButtonScale, actionButtonScale);

    
    // Action button - Make translate
    
    // This is because we are making scale and translate at the same time. We have to
    // compasate the new size in the translation.
    CGFloat compensationBecauseOfMakingScale = (self.actionButtonWidthConstraint.constant - newActionButtonSize) / 2.0;
    
    CGFloat actionButtonTranslationY =
    (progress * kActionButtonDisplacement) +
    compensationBecauseOfMakingScale;
   
    CGAffineTransform actionButtonTranslateTransform =
    CGAffineTransformMakeTranslation(0, actionButtonTranslationY);
    
    CGAffineTransform actionButtonTransform =
    CGAffineTransformConcat(actionButtonScaleTransform, actionButtonTranslateTransform);
    
    self.actionButton.transform = actionButtonTransform;
}

#pragma mark - Transition

- (CGFloat)transitionAnimationDuration
{
    return 0.25;
}

- (void)dismissOverViewController
{
    [self finishInteractiveTransition];
}

- (void)presentOverViewController
{
    [self finishInteractiveTransition];
}

- (void)updateInteractiveTransition:(CGFloat)progress
{
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.mainViewController updateInteractiveTransition:progress];
    [self.overViewController updateInteractiveTransition:progress];
    
    [self transformContentWithProgress:progress];
}

- (void)cancelInteractiveTransition
{
    self.overViewTopEstimatedValue = self.overViewTopConstraint.constant;
    
    [self.mainViewController cancelInteractiveTransition];
    [self.overViewController cancelInteractiveTransition];
    
    __block typeof(self) blockSelf = self;
    
    void (^AnimationBlock)(void) = ^void (void)
    {
        blockSelf.overViewContainer.transform = CGAffineTransformIdentity;
        blockSelf.actionButton.transform = CGAffineTransformIdentity;
    };

    void (^CompletionBlock)(BOOL finished) = ^void (BOOL finished)
    {
        [blockSelf setNeedsStatusBarAppearanceUpdate];
    };
    
    [UIView animateWithDuration:[self transitionAnimationDuration]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:AnimationBlock
                     completion:CompletionBlock];
}

- (void)finishInteractiveTransition
{
    [self.mainViewController finishInteractiveTransition];
    [self.overViewController finishInteractiveTransition];
    
    CGFloat progress = (self.isOverViewVisible ? -1 : 1);
    
    CGFloat newOverViewTopConstraintConstant =
    (self.isOverViewVisible ?
     -[UIScreen mainScreen].bounds.size.height :
     0);
    
    CGFloat newActionButtonBottomConstraintConstant =
    (self.isOverViewVisible ?
     self.originalActionButtonBottomConstraintConstant :
     self.originalActionButtonBottomConstraintConstant -
     kActionButtonDisplacement);
    
    CGFloat newActionButtonWidthConstraintConstant =
    (self.isOverViewVisible ?
     self.originalActionButtonWidthConstraintConstant :
     kActionButtonSmallSize);
    
    __block typeof(self) blockSelf = self;
    
    void (^AnimationBlock)(void) = ^void (void)
    {
        [blockSelf transformContentWithProgress:progress];
    };
    
    void (^CompletionBlock)(BOOL finished) = ^void (BOOL finished)
    {
        blockSelf.overViewTopConstraint.constant =
        newOverViewTopConstraintConstant;
        
        blockSelf.overViewTopEstimatedValue = newOverViewTopConstraintConstant;
        
        blockSelf.actionButtonBottomConstraint.constant =
        newActionButtonBottomConstraintConstant;
        
        blockSelf.actionButtonWidthConstraint.constant =
        newActionButtonWidthConstraintConstant;
        
        blockSelf.overViewContainer.transform = CGAffineTransformIdentity;
        blockSelf.actionButton.transform = CGAffineTransformIdentity;
        
        [blockSelf.view layoutIfNeeded];
        
        blockSelf.overViewVisible = !blockSelf.isOverViewVisible;
        
        [blockSelf setNeedsStatusBarAppearanceUpdate];
    };
    
    [UIView animateWithDuration:[self transitionAnimationDuration]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:AnimationBlock
                     completion:CompletionBlock];
}

#pragma mark - Gesture

- (void)addGestureRecogniserOnView:(UIView*)view
{
    UIPanGestureRecognizer *panGesture =
    [[UIPanGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleGestureRecognizer:)];
    
    [view addGestureRecognizer:panGesture];
}

- (void)handleGestureRecognizer:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint velocity = [gesture velocityInView:self.view];
    
    CGFloat progress = translation.y / self.view.frame.size.height;

    progress =
    (self.isOverViewVisible ?
     fmin(0.0, fmax(-1.0, progress)) :
     fmin(1.0, fmax(0.0, progress)));
    
//    NSLog(@"%f", progress);
//    NSLog(@"%f", translation.y);
//    NSLog(@"%f", velocity.y);
    
    static CGFloat const kVelocityLimit = 2000.0;
    static CGFloat const kTranslationLimit = 0.30;
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            
            self.shouldCompleteTransition = NO;
            self.interactionInProgress = YES;
            
            break;
            
        case UIGestureRecognizerStateChanged:
            
            if (self.isInteractionInProgress)
            {
                // Stop because of velocity
                if ((self.isOverViewVisible && velocity.y < -kVelocityLimit) ||
                    (!self.isOverViewVisible && velocity.y > kVelocityLimit))
                {
                    self.interactionInProgress = NO;
                    [self finishInteractiveTransition];
                }
                else
                {
                    // Stop because of position, but we will complete the transition
                    // when the user completes the gesture.
                    self.shouldCompleteTransition =
                    (self.isOverViewVisible ?
                     progress < -kTranslationLimit:
                     progress > kTranslationLimit);
                    
                    [self updateInteractiveTransition:progress];
                }
            }
            
            break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            
            if (self.isInteractionInProgress)
            {
                self.interactionInProgress = NO;
                [self cancelInteractiveTransition];
            }
            
            break;
            
        case UIGestureRecognizerStateEnded:
            
            if (self.isInteractionInProgress)
            {
                self.interactionInProgress = NO;
                
                if (self.shouldCompleteTransition)
                {
                    [self finishInteractiveTransition];
                }
                else
                {
                    [self cancelInteractiveTransition];
                }
            }
            
            break;
            
        case UIGestureRecognizerStatePossible:
            // Do nothing
            break;
    }
}


@end
