//
//  MapManager.h
//  PublicMapModule
//
//  Created by TOPBAND on 2022/1/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TBMapManager : NSObject

-(void)drawPublicMapView:(UIView *)superView mapData:(NSData *)mapData;

@end

NS_ASSUME_NONNULL_END
