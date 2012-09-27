//
//  IAmCoder.h
//  PrizeKing
//
//  Created by Andrés Abril on 26/07/12.
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>


@interface IAmCoder : NSObject

+(NSString*)encodeURL:(NSString*)url;
+(NSString*)decodeURL:(NSString*)url;
+(NSString*)hash256:(NSString*)parameters;
@end
