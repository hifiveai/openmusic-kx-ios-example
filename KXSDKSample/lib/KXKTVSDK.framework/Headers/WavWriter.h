//
//  WavWriter.h
//  KXKTVSDK
//
//  Created by KXKTVSDK on 22/6/5.
//
//

#import <Foundation/Foundation.h>

@interface WavWriter : NSObject

- (NSString *)getFilePath;

- (int)open:(NSString*)aFileName samprate:(UInt32)aSamprate channels:(UInt32)aChannel;
- (void)finishWrite;
- (void)write:(Byte*)aData size:(UInt32)aSize;
- (void)write:(NSData*)aData;

@end
