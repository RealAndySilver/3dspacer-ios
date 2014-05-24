//
//  Project+AddOn.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Project+AddOn.h"

@implementation Project (AddOn)

-(UIImage *)projectLogoImage {
    return [UIImage imageWithData:self.logoData];
}

-(UIImage *)projectMainImage {
    return [UIImage imageWithData:self.imageData];
}

@end
