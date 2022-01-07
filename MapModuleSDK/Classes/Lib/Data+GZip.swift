//
//  Data+GZip.swift
//  FloorSweepingRobotVM690Module
//
//  Created by 马伟龙 on 2019/5/31.
//

import Foundation
import zlib
/**解压缩流大小**/
private let GZIP_STREAM_SIZE: Int32 = Int32(MemoryLayout<z_stream>.size)
/**解压缩缓冲区大小**/
private let GZIP_BUF_LENGTH:Int = 512
/**默认空数据**/
private let GZIP_NULL_DATA = NSData()


extension Data {
    // 判断是否zip压缩后的数据
    public var isGZipCompressed :Bool {
        return self.starts(with: [0x1f,0x8b])
    }
    
    // 解压
    public func gzipUncompress() -> NSData {
        guard self.count > 0  else {
            return GZIP_NULL_DATA
        }
        
        guard self.isGZipCompressed else {
            return self as NSData
        }
        
        var  stream = z_stream()
        
        self.withUnsafeBytes { (bytes:UnsafePointer<Bytef>) in
            stream.next_in =  UnsafeMutablePointer<Bytef>(mutating: bytes)
        }
        
        stream.avail_in = uInt(self.count)
        stream.total_out = 0
        
        var status: Int32 = inflateInit2_(&stream, MAX_WBITS + 16, ZLIB_VERSION,GZIP_STREAM_SIZE)
        
        guard status == Z_OK else {
            return GZIP_NULL_DATA as NSData
        }
        
        var decompressed = Data(capacity: self.count * 2)
        while stream.avail_out == 0 {
            
            stream.avail_out = uInt(GZIP_BUF_LENGTH)
            decompressed.count += GZIP_BUF_LENGTH
            
            decompressed.withUnsafeMutableBytes { (bytes:UnsafeMutablePointer<Bytef>)in
                stream.next_out = bytes.advanced(by: Int(stream.total_out))
            }
            
            status = inflate(&stream, Z_SYNC_FLUSH)
            
            if status != Z_OK && status != Z_STREAM_END {
                break
            }
        }
        
        if inflateEnd(&stream) != Z_OK {
            return GZIP_NULL_DATA
        }
        
        decompressed.count = Int(stream.total_out)
        return decompressed as NSData
    }
}


