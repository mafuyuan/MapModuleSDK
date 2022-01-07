//
//  LZ4ZipUncompressTool.m
//  PublicMapModule
//
//  Created by TOPBAND on 2022/1/5.
//

#import "LZ4ZipUncompressTool.h"
#include "compression.h"

@implementation LZ4ZipUncompressTool

-(NSData *)lz4ZipUncompress:(NSData *)srcData {
    
    size_t destSize = 217*168;
    uint8_t *destBuf = malloc(sizeof(uint8_t) * destSize);
    const uint8_t *src_buffer = (const uint8_t *)[srcData bytes];
    size_t src_size = srcData.length;

    size_t decompressedSize = compression_decode_buffer(destBuf, destSize, src_buffer, src_size,
                                                        NULL, COMPRESSION_LZ4_RAW);
    NSLog(@"after decompressed. length = %d",decompressedSize) ;
    NSData *data = [NSData dataWithBytesNoCopy:destBuf length:decompressedSize freeWhenDone:YES];
    return data;
}

@end
