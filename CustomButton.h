//
//  CustomButton.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/07/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Proyecto.h"

@interface CustomButton : UIButton{
}
@property(nonatomic)int secondaryId;
@property(nonatomic)NSString *url;
@property(nonatomic)id extraContent;


@end
