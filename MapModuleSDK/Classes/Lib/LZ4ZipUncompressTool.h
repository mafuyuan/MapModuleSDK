//
//  LZ4ZipUncompressTool.h
//  PublicMapModule
//
//  Created by TOPBAND on 2022/1/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZ4ZipUncompressTool : NSObject

/// LZ4数据解压
/// @param srcData 需要解压的数据
-(NSData *)lz4ZipUncompress:(NSData *)srcData;

@end

NS_ASSUME_NONNULL_END
