//
//  SatellitesView.m
//  Satellites
//
//  Created by Richard Benjamin Heidorn on 4/20/14.
//  Copyright (c) 2014 Richard B Heidorn. All rights reserved.
//

#import "SatellitesView.h"

@implementation SatellitesView

@synthesize baseEffect;
@synthesize controller;
@synthesize system;
@synthesize satelliteModel;
@synthesize spheres;
@synthesize bodies;
@synthesize skybox;
@synthesize eyePosition;
@synthesize lookAtPosition;
@synthesize targetEyePosition;
@synthesize targetLookAtPosition;
@synthesize rotation;
@synthesize scale;

- (id) init
{
    self = [super init];
    if (self)
    {
        [self loadView];
    }
    
    return self;
}

- (id) initWithFrame: (CGRect) screenRect
{
    self = [super initWithFrame:screenRect];
    if (self)
    {
        [self loadView];
    }
    
    return self;
}

- (id) initWithFrame: (CGRect) screenRect context: (EAGLContext *) context
{
    self = [super initWithFrame:screenRect context:context];
    if (self)
    {
        [self loadView];
    }
    
    return self;
}

- (void) initSystem
{
    // Check for a valid system
    if (system != nil)
    {
        // Initialize the controller with the system at hand
        controller = [[SatellitesController alloc] initWithSystemObject: system];
    }
    else
    {
        // Initialize the controller with default parameters
        controller = [[SatellitesController alloc] init];
    }
    
    // Get the bodies
    bodies = controller.bodies;
}

// Not necessary?
- (void) loadView
{
    // Hide the toolbar
    //self.navigationController.toolbarHidden = true;
    
    // Create the system
    [self initSystem];
    
    // Perform the setup operations
    [self initViewContext];
    
    // Create a base effect that provides standard OpenGL ES 2.0
    [self initBaseEffect];
    
    // Initiate gestures
    [self initGestureRecognizers];
    
    // Initialize the camera
    [self initCamera];
    
    // Set the background color of the current context
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    // Context parameters
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Generate, bind, and initialize contents of a buffer to be stored in GPU memory
    [self drawElements];
    
    // Lastly, provide the skybox
    [self initSkybox];
}

// View context
- (void) initViewContext
{
    // Create the GLKView & ensure creation
    NSAssert([self isKindOfClass : [GLKView class]], @"View controller's view is not a GLKView");
    
    // Set the drawable depth
    self.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    // Create an OpenGL ES 2.0 context and provide it to the view, then set current
    self.context = [[EAGLContext alloc] initWithAPI : kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext : self.context];
}

// Base Effect
- (void) initBaseEffect
{
    // Create a base effect that provides standard OpenGL ES 2.0
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.lightingType           = GLKLightingTypePerPixel;
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    self.baseEffect.colorMaterialEnabled   = GL_TRUE;
    
    self.baseEffect.texture2d0.envMode = GLKTextureEnvModeModulate;
    
    self.baseEffect.light0.enabled      = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.5f, 0.2f, 0.2f, 1.0f);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    self.baseEffect.light0.position     = GLKVector4Make(0.0f, 0.0f, 0.1f, 0.0f);
}

// Gestures
- (void) initGestureRecognizers
{
    // Pinch
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleScale:)];
    [self addGestureRecognizer : pinch];
}

// Camera Properties
- (void) initCamera
{
    // Set initial point of view
    self.eyePosition    = GLKVector3Make(0.0, 0.0, 100.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    
    // Set initial alteration to the pov
    self.targetEyePosition    = GLKVector3Make(0.0, 0.0, 0.0);
    self.targetLookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    
    // Set the current matrix propertites
    self.scale = 0.6;
    self.rotation = GLKVector3Make(0.0, 0.0, 0.0);
}

// Draw elements that belong in the scene
- (void) drawElements
{
    // Initialize the bodies
    spheres = [[NSMutableArray alloc] init];
    
    for (Satellite * body in bodies)
    {
        // Create the sphere
        SceneSatellite * sphere = [[SceneSatellite alloc]
                                   initWithPosition : GLKVector3Make(0.0, 0.0, 0.0)
                                   rotation : body.rotationSpeed
                                   tilt     : body.axialTilt
                                   radius   : body.size
                                   color    : GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)
                                   texture  : body.texture];
        
        // Add to our collection
        [spheres addObject : sphere];
    }
}

- (void) initSkybox
{
    // Get all six textures
    NSArray * paths = [[NSArray alloc] initWithObjects:
                       [[NSBundle bundleForClass:[self class]] pathForResource:@"right" ofType:@"png" inDirectory:@"skybox"],
                       [[NSBundle bundleForClass:[self class]] pathForResource:@"left" ofType:@"png" inDirectory:@"skybox"],
                       [[NSBundle bundleForClass:[self class]] pathForResource:@"south" ofType:@"png" inDirectory:@"skybox"],
                       [[NSBundle bundleForClass:[self class]] pathForResource:@"north" ofType:@"png" inDirectory:@"skybox"],
                       [[NSBundle bundleForClass:[self class]] pathForResource:@"top" ofType:@"png" inDirectory:@"skybox"],
                       [[NSBundle bundleForClass:[self class]] pathForResource:@"bottom" ofType:@"png" inDirectory:@"skybox"],
                       nil];
    
    // Get the texture infomation
    NSError *error = nil;
    GLKTextureInfo *skyboxTextureInfo = [GLKTextureLoader cubeMapWithContentsOfFiles:paths options:nil error:&error];
    NSAssert(nil != skyboxTextureInfo, @"Invalid skyboxTextureInfo: %@", error);
    
    // Create the skybox
    self.skybox = [[GLKSkyboxEffect alloc] init];
    self.skybox.textureCubeMap.name   = skyboxTextureInfo.name;
    self.skybox.textureCubeMap.target = skyboxTextureInfo.target;
    
    // Size up the skybox
    GLfloat maxDimension = 3000.0f;
    self.skybox.xSize = maxDimension;
    self.skybox.ySize = maxDimension;
    self.skybox.zSize = maxDimension;
    //self.skyboxEffect.center = GLKVector3Make(0.5f * maxDimension, 0.5f * maxDimension, 0.5f * maxDimension);
    self.skybox.center = GLKVector3Make(0.0f, 0.0f, 0.0f);
}

// Update operations
- (void) update
{
    // Calculate new positions
    [controller performCalculations];
    
    // Update scene
    [self updateCameraPosition];
}

// Any changes to the camera position
- (void) updateCameraPosition
{
    // Set the model view matrix to match current eye and look-at positions
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z,
                                                      self.lookAtPosition.x, self.lookAtPosition.y, self.lookAtPosition.z,
                                                      0, 1, 0);
    
    // Alter the view matrix
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(rotation.y / 10.0), 1.0, 0.0, 0.0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(rotation.x / 10.0), 0.0, 1.0, 0.0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, scale, scale, scale);
    
    // Set the model view matrix
    self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Clear Frame Buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Calculate the aspect ratio for the scene and setup a perspective projection
    const GLfloat aspectRatio = (GLfloat) view.drawableWidth / (GLfloat) view.drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f), aspectRatio, 0.01f, 5000.0f * scale);
    
    // Reposition all of the bodies to the scaled amount
    [self drawSatellites];
    
    // Draw the skybox
    [self drawSkybox];
}

- (void) castLight : (GLint) lightNum : (GLfloat) x : (GLfloat) y : (GLfloat) z
{
    GLKEffectPropertyLight * light;
    switch (lightNum)
    {
        case 1:
            light = self.baseEffect.light1;
            break;
        case 0:
        default:
            light = self.baseEffect.light0;
            break;
    }
    
    //light.enabled = GL_TRUE;
    //light.spotCutoff = 180.0f;
    //light.spotExponent = 45.0f;
    light.ambientColor = GLKVector4Make(0.1f, 0.1f, 0.1f, 1.0f);
    light.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    //light.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    light.position = GLKVector4Make(x, y, z, 1.0f);
    //light.quadraticAttenuation = 0.000002f;
    [self.baseEffect prepareToDraw];
}

- (void) drawSkybox
{
    glDisable(GL_BLEND);
    
    self.skybox.transform.projectionMatrix = self.baseEffect.transform.projectionMatrix;
    self.skybox.transform.modelviewMatrix  = GLKMatrix4Translate(self.baseEffect.transform.modelviewMatrix, self.lookAtPosition.x, self.lookAtPosition.y, self.lookAtPosition.z);
    
    [self.skybox prepareToDraw];
    [self.skybox draw];
    glBindVertexArrayOES(0);
}

- (void) drawSatellites
{
    int i = 0;
    GLint starCount = 0;
    for (Satellite * body in bodies)
    {
        // Redraw each body
        float x = body.position.x / 40;
        float y = body.position.y / 40;
        float z = body.position.z / 40;
        
        // If this body is a star, illuminate
        if ([body isStar])
        {
            //[self castLight : starCount : x : y : z];
            //[self disableLighting];
        }
        
        // If this body is a moon, increase the spacing
        if (body.isMoon)
        {
            x += (body.position.x - body.orbitalBody.position.x);
            y += (body.position.y - body.orbitalBody.position.y);
            z += (body.position.z - body.orbitalBody.position.z);
        }
        
        [spheres[i]   updateBody : x : y : z];
        [spheres[i++] drawWithBaseEffect : self.baseEffect];
        
        // If we're done with the star, turn the light back on
        if ([body isStar])
        {
            //[self enableLighting];
            starCount++;
        }
    }
}

- (void) disableLighting
{
    self.baseEffect.light1.enabled = GL_FALSE;
    self.baseEffect.light0.enabled = GL_FALSE;
}

- (void) enableLighting
{
    self.baseEffect.light1.enabled = GL_TRUE;
    self.baseEffect.light0.enabled = GL_TRUE;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { }

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count]) // Rotate this shit
	{
        // Movement -> Rotate
        [self handleRotate : touches withEvent: event];
    }
}

- (void) handleRotate: (NSSet *) touches withEvent: (UIEvent *) event
{
    UITouch* t = [touches anyObject];
    rotation.x += ([t locationInView:self].x - [t previousLocationInView:self].x);
    rotation.y += ([t locationInView:self].y - [t previousLocationInView:self].y);
}

- (void) handleScale : (UIPinchGestureRecognizer*) sender
{
    // Don't allow the user to go too far out
    if (scale < 0.15 && sender.scale < scale)
    {
        return;
    }
    
    if ([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan)
    {
        sender.scale = scale;
    }
    else if ([(UIPinchGestureRecognizer*)sender state] != UIGestureRecognizerStateEnded)
    {
        scale = sender.scale;
    }
}

// Not necessary?
- (void)viewDidUnload
{
    // Make the view's context current
    GLKView *view = (GLKView *) self;
    [EAGLContext setCurrentContext:view.context];
    
    // Delete buffers that aren't needed when view is unloaded
    self.controller = nil;
    self.spheres    = nil;
    self.bodies     = nil;
    self.skybox     = nil;
    
    // Stop using the context created in -viewDidLoad
    ((GLKView *) self).context = nil;
    [EAGLContext setCurrentContext:nil];
}

@end