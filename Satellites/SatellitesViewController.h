//
//  SatellitesViewController.h
//  Satellites
//
//  Created by Richard Benjamin Heidorn on 4/14/13.
//  Copyright (c) 2013 Richard B Heidorn. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "Vector.h"
#import "SatellitesController.h"
#import "SceneSatelliteModel.h"
#import "SceneSatellite.h"
#import "SystemObject.h"

@interface SatellitesViewController : GLKViewController
{
    SatellitesController * controller;

    SystemObject         * system;
    NSMutableArray       * satellites;
    
    NSMutableArray       * spheres;
    NSMutableArray       * bodies;
    GLKSkyboxEffect      * skybox;
    
    BOOL                   bEditorView;
    BOOL                   bUpdateSatellites;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) SatellitesController * controller;
@property (strong, nonatomic) SceneModel * satelliteModel;

// Need to be cleaned up
@property (strong, nonatomic) SystemObject * system;
@property (strong, nonatomic) NSMutableArray * satellites;

@property (strong, nonatomic) NSMutableArray * spheres;
@property (strong, nonatomic) NSMutableArray * bodies;
@property (strong, nonatomic) GLKSkyboxEffect * skybox;
@property (nonatomic, assign) GLKVector3 eyePosition;
@property (nonatomic, assign) GLKVector3 lookAtPosition;
@property (nonatomic, assign) GLKVector3 targetEyePosition;
@property (nonatomic, assign) GLKVector3 targetLookAtPosition;
@property (nonatomic, assign) GLKVector3 rotation;
@property (nonatomic, assign) GLfloat scale;
@property (nonatomic, assign) BOOL bEditorView;
@property (nonatomic, assign) BOOL bUpdateSatellites;

// C'mon, c'mon, c'mon, c'mon, now touch me babe
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)useEditorView:(BOOL)bUseView;
- (Satellite *)getSatelliteByName:(NSString *)name;
- (void)propogateChanges:(Satellite *)satellite forProperty:(NSString *)property;

@end
