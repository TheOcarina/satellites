//
//  SatellitesView.h
//  Satellites
//
//  Created by Richard Benjamin Heidorn on 4/20/14.
//  Copyright (c) 2014 Richard B Heidorn. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "Vector.h"
#import "SatellitesController.h"
#import "SceneSatelliteModel.h"
#import "SceneSatellite.h"
#import "SystemObject.h"
#import "SatelliteObject.h"

@interface SatellitesView : GLKView
{
    SatellitesController * controller;
    SystemObject         * system;
    NSMutableArray       * spheres;
    NSMutableArray       * bodies;
    GLKSkyboxEffect      * skybox;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) SatellitesController * controller;
@property (strong, nonatomic) SystemObject         * system;
@property (strong, nonatomic) SceneModel * satelliteModel;
@property (strong, nonatomic) NSMutableArray * spheres;
@property (strong, nonatomic) NSMutableArray * bodies;
@property (strong, nonatomic) GLKSkyboxEffect * skybox;
@property (nonatomic, assign) GLKVector3 eyePosition;
@property (nonatomic, assign) GLKVector3 lookAtPosition;
@property (nonatomic, assign) GLKVector3 targetEyePosition;
@property (nonatomic, assign) GLKVector3 targetLookAtPosition;
@property (nonatomic, assign) GLKVector3 rotation;
@property (nonatomic, assign) GLfloat scale;

// C'mon, c'mon, c'mon, c'mon, now touch me babe
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

// Temporary? I'll see this comment in 2015.
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect;

@end