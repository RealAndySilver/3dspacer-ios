//
//  SlideshowViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/08/13.
//  Copyright (c) 2013 Ekoomedia. All rights reserved.
//

typedef NS_ENUM(NSInteger, KASlideShowTransitionType) {
    KASlideShowTransitionFade,
    KASlideShowTransitionSlide
};

@class KASlideShowDelegate;
@protocol KASlideShowDelegate <NSObject>
@optional
- (void) kaSlideShowDidNext;
- (void) kaSlideShowDidPrevious;
@end

@interface KASlideShow : UIView

@property (nonatomic, unsafe_unretained) IBOutlet id <KASlideShowDelegate> delegate;

@property  float delay;
@property  float transitionDuration;
@property  (atomic) KASlideShowTransitionType transitionType;
@property  (atomic) UIViewContentMode imagesContentMode;
@property  (strong,nonatomic) NSMutableArray * images;

- (void) addImagesFromResources:(NSArray *) names;
- (void) addImage:(UIImage *) image;
- (void) start;
- (void) stop;
- (void) previous;
- (void) next;

@end

