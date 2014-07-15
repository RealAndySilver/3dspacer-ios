//
//  ImageSaver.m
//  Ekoobot 3D
//
//  Created by Developer on 14/07/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "ImageSaver.h"
#import "FinishImage.h"
#import "UIImage+Resize.h"
#import "Render.h"

@implementation ImageSaver

////////////////////////////////////////////////////////////////////////////////////
//FinishImages

+(void)saveFinishImage:(FinishImage *)finishImage atPath:(NSString *)jpegFilePath {
    NSLog(@"Entré a guardar la imagen");
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExist) {
        NSLog(@"La imagen no existía en documents directory, así que la guardaré");
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finishImage.imageURL]];
        if (!data) {
            return;
        }
        
        if ([finishImage.imageURL rangeOfString:@".jpg"].location == NSNotFound) {
            //PVR Image
            NSLog(@"Guardando imagen PVR");
            [data writeToFile:jpegFilePath atomically:YES];
        } else {
            //JPG Image
            UIImage *image = [UIImage imageWithData:data];
            if (!image) {
                //Error downloading
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorDownloadingNotification" object:nil];
                return;
            }
            if ([finishImage.finalSize intValue] != [finishImage.size intValue]) {
                NSLog(@"Cambiaré el tamaño de la imagen");
                UIImage *newImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake([finishImage.finalSize intValue], [finishImage.finalSize intValue])];
                NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(newImage, 1.0)];
                [imageData writeToFile:jpegFilePath atomically:YES];
                
            } else {
                NSLog(@"No tuve que cambiar el tamaño de la imagen");
                NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
                [imageData writeToFile:jpegFilePath atomically:YES];
            }
        }
        
    } else {
        NSLog(@"La imagen ya existía, así que no la guardé en documents directory");
    }
}

+(void)deleteImagesAtPaths:(NSArray *)imagePaths {
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    for (int i = 0; i < [imagePaths count]; i++) {
        NSString *finishImagePath = [docDir stringByAppendingPathComponent:imagePaths[i]];
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:finishImagePath];
        if (fileExist) {
            [[NSFileManager defaultManager] removeItemAtPath:finishImagePath error:NULL];
            NSLog(@"Borrando Imagen del proyecto en la ruta %@", finishImagePath);
        } else {
            NSLog(@"No había archivo del proyecto en la ruta %@", finishImagePath);
        }
    }
}

+(void)saveImageWithURL:(NSString *)imageURL atPath:(NSString *)filePath {
    //If the url is null, don't save anything
    if (!imageURL || [imageURL isEqualToString:@""]) {
        return;
    } else {
        NSLog(@"image urllllllllllllllllllll: %@", imageURL);
    }
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!fileExists) {
        NSLog(@"La imagen no existe, así que la guardaré");
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *image = [UIImage imageWithData:data];
        if (!image) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorDownloadingNotification" object:nil];
        } else {
            NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
            [imageData writeToFile:filePath atomically:YES];
        }

    } else {
        NSLog(@"La imagen del render ya existía, así que no la guardaré");
    }
}

@end
