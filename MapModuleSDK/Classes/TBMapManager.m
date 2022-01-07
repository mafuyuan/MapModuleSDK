//
//  MapManager.m
//  PublicMapModule
//
//  Created by TOPBAND on 2022/1/7.
//

#import "TBMapManager.h"
#import <MapModuleSDK/MapModuleSDK-Swift.h>
@implementation TBMapManager

-(void)drawPublicMapView:(UIView *)superView mapData:(NSData *)mapData{
    
    BitMapModel *model = [[BitMapModel alloc]init];
    model.cleanedColor = @"#e8e8e8";
    model.unCleanColor = @"#f7f7f7";
    model.obstacleColor = @"#979797";
    model.pathColor = @"#FF62FF";
    model.mapScale = 3;
    model.robotImage = [UIImage imageNamed:@"icon_robot_r60"];
    model.chargeImage = [UIImage imageNamed:@"icon_charge"];
    
    RotateMapManager *mapManager = [[RotateMapManager alloc]initWithModel:model];
    [mapManager drawPublicMapViewWithSuperView:superView mapData:mapData];
}

@end
