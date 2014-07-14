//
//  ImageSaver.h
//  Ekoobot 3D
//
//  Created by Developer on 14/07/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FinishImage;
@class Render;

@interface ImageSaver : NSObject
+(void)saveFinishImage:(FinishImage *)finishImage atPath:(NSString *)jpegFilePath;
+(void)deleteImagesAtPaths:(NSArray *)imagePaths;
+(void)saveImageWithURL:(NSString *)imageURL atPath:(NSString *)filePath;
@end
