//
//  EditingViewController.m
//  Satellites
//
//  Created by Richard Benjamin Heidorn on 5/28/13.
//  Copyright (c) 2013 Richard B Heidorn. All rights reserved.
//

#import "EditingViewController.h"

@implementation EditingViewController

@synthesize editedFieldKey;
@synthesize editedFieldName;
@synthesize editedObject;
@synthesize slider;
@synthesize units;
@synthesize unitRange;
@synthesize currentUnit;
@synthesize textField;
@synthesize nameTextField;
@synthesize unitField;
@synthesize activityActionSheet;
@synthesize satellite;
@synthesize satellitesViewController;
@synthesize system;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Control the text field
    self.textField.delegate = self;
    self.nameTextField.delegate = self;
    
    // Set the title to the user-visible name of the field.
    self.title = self.editedFieldName;
    
    CGRect screenRect;
    screenRect.size.height = [UIScreen mainScreen].bounds.size.height;
    screenRect.size.width  = [UIScreen mainScreen].bounds.size.width + 20;
    screenRect.origin.y    = 0; // 110
    screenRect.origin.x    = -10;
    
    // Prepare to send satellites to view controller
    NSMutableArray * satellites = [[NSMutableArray alloc] init];
    
    // Prepare the satellite object if we're editing a satellite
    SatelliteObject * satelliteObject;
    
    // If we're editing the system, load all of the satellites
    if (self.editedObject == self.system)
    {
        // Only show the stars
        [satellites addObjectsFromArray:[[system.satellites allObjects] mutableCopy]];
    }
    // Show more than just this satellite if we need to
    else if ([editedFieldName isEqualToString:@"Distance"] ||
        [editedFieldName isEqualToString:@"Eccentricity"] ||
        [editedFieldName isEqualToString:@"Inclination"])
    {
        // Show this satellite and its primary orbital partner
        satelliteObject = (SatelliteObject *) editedObject;
        
        if ([satelliteObject bMoon])
        {
            // If this is a moon, add its parent
            [satellites addObject:[satelliteObject orbitalBody]];
            [satellites addObject:satelliteObject];
        }
        else if ([satelliteObject bStar])
        {
            // Only show the stars
            NSMutableArray * stars = [[[system getStars] allObjects] mutableCopy];
            [satellites addObjectsFromArray:stars];
        }
        else
        {
            // Show the planet with the stars
            NSMutableArray * stars = [[[system getStars] allObjects] mutableCopy];
            [satellites addObjectsFromArray:stars];
            [satellites addObject:satelliteObject];
        }
    }
    else
    {
        // Just show this one satellite
        satelliteObject = (SatelliteObject *) editedObject;
        [satellites addObject:satelliteObject];
    }

    // Create and instantiate the satellite view controller
    satellitesViewController = [[SatellitesViewController alloc] init];
    [satellitesViewController useEditorView: true];
    [satellitesViewController setSatellites: satellites];

    // Set the satellites view controller in the view
    [satellitesViewController.view setFrame:screenRect];
    [self.view addSubview:satellitesViewController.view];
    [self addChildViewController:satellitesViewController];
    [self.view sendSubviewToBack:satellitesViewController.view];
    [satellitesViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
    self.navigationController.navigationBar.translucent = NO;

    // Get this edited satellite
    SatelliteObject * satelliteObject = (SatelliteObject *) editedObject;
    satellite = [satellitesViewController getSatelliteByManagedObject: satelliteObject];
    
    // Get the value
    id value = [self.editedObject valueForKey:self.editedFieldKey];

    // If we're altering the name, only show the name field
    if ([editedFieldKey isEqualToString:@"name"])
    {
        // Set the name field
        [nameTextField setHidden:NO];
        [nameTextField setText:value];

        [slider setHidden:YES];
        [textField setHidden:YES];
        [unitField setHidden:YES];
        return;
    }
    else
    {
        [nameTextField setHidden:YES];
        [slider setHidden:NO];
        [textField setHidden:NO];
        [unitField setHidden:NO];
    }

    // Set the unit and value
    currentUnit = [[Unit alloc] initWithBaseValue:value forUnit:[units objectAtIndex:0]];
    value = [currentUnit getValue];

    // Prepare UI elements
    [self prepareTextField];
    [self prepareSlider];
    [self prepareUnitOfMeasurementActionSheet];
    
    // Get the value
    [self updateSliderValue:[value floatValue]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Set the edited satellite as the central body
    //[satellitesViewController setCentralBody:satellite];

    // Use log mode
    [satellitesViewController setBLogMode:YES];
}

// Drop the keyboard when the return button is pressed
- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
    // Only if the text field is available
    if ([textField isHidden])
    {
        return YES;
    }
    
    // Float this shit
    NSString * textValue = sender.text;
    float value = [textValue floatValue];
    
    // Validate that we are within range
    float min = [slider minimumValue];
    float max = [slider maximumValue];
    if (min > value)
    {
        value = min;
        [textField setText:[NSString stringWithFormat:@"%1.3f", value]];
    }
    else if (max < value)
    {
        value = max;
        [textField setText:[NSString stringWithFormat:@"%1.3f", value]];
    }
    
    // Update slider value
    [slider setValue:value];
    [currentUnit setValue:[[NSNumber alloc] initWithFloat:value]];
    
    // Update satellite
    [self updateSatellite];

    // Resign the text field
    [sender resignFirstResponder];
    return YES;
}

- (void) prepareTextField
{
    self.textField.placeholder = self.title;
    //[textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void) prepareSlider
{
    // Handle the slider value change event
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    // Set the min and max values for the slider
    [self setRange];
}

- (void) setRange
{
    // Only if the slider is available
    if ([slider isHidden])
    {
        return;
    }
    
    // Get the min and max
    NSNumber * min = [unitRange objectForKey:@"min"];
    NSNumber * max = [unitRange objectForKey:@"max"];

    // Set the range
    [slider setMinimumValue:[min floatValue]];
    [slider setMaximumValue:[max floatValue]];
}

// When the slider value is changed, alter the text value
- (IBAction) sliderValueChanged : (UISlider *) sender
{
    // Update the text field
    NSString * value = [NSString stringWithFormat:@"%1.3f", sender.value];
    [textField setText : value];
    
    // Update the unit
    [currentUnit setValue:[[NSNumber alloc] initWithFloat:sender.value]];

    // Update satellite
    [self updateSatellite];
}

- (void) updateSliderValue : (float) value
{
    [slider setValue:value];
    
    // Update the text field
    NSString * textValue = [NSString stringWithFormat:@"%1.3f", value];
    [textField setText : textValue];
    
    // Update satellite
    [self updateSatellite];
}

- (void) updateSatellite
{
    // Update satellite
    NSString * fieldName = [[NSString alloc] initWithString:editedFieldName];
    NSNumber * numValue;
    
    // Name field does not have a unit
    if ([nameTextField isHidden])
    {
        numValue = [currentUnit getBaseValue];
    }
    
    // Make sure we're using a valid field name
    if ([fieldName isEqualToString:@"Axial Tilt"])
    {
        fieldName = @"axialTilt";
    }
    else if ([fieldName isEqualToString:@"Rotation"])
    {
        fieldName = @"rotationSpeed";
    }
    else if ([fieldName isEqualToString:@"Mass"])
    {
        fieldName = @"mass";
    }
    else if ([fieldName isEqualToString:@"Eccentricity"])
    {
        fieldName = @"eccentricity";
    }
    else if ([fieldName isEqualToString:@"Inclination"])
    {
        fieldName = @"inclination";
    }
    else if ([fieldName isEqualToString:@"Distance"])
    {
        fieldName = @"semimajorAxis";
        [satellite updateDistance:[numValue floatValue] * 1000];
    }
    
    // Set the new value
    [satellite updateField:fieldName withValue:numValue];
    [satellitesViewController propogateChanges:satellite forProperty:fieldName];
}

- (void) prepareUnitOfMeasurementActionSheet
{
    activityActionSheet = [[UIActionSheet alloc] initWithTitle:@"Unit of Measurement"
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:@"Cancel"
                                             otherButtonTitles:nil];

    // Set the buttons
    for (NSString * buttonName in units)
    {
        [activityActionSheet addButtonWithTitle:buttonName];
    }
    
    // Update the button name
    if ([units count] > 0)
    {
        NSString * uomAbbr = [currentUnit getAbbr];
        [unitField setTitle:uomAbbr forState:UIControlStateNormal];
    }
    else
    {
        [unitField setHidden:true];
    }
}

- (IBAction) setUserActivity: (id) sender
{
    activityActionSheet.tag = 1;
    [activityActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [activityActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        return;
    }
    
    // Get the new unit name
    NSString * unitName = [units objectAtIndex:buttonIndex - 1];
    
    // Update the range
    NSNumber * minValue = [currentUnit convertValue:[unitRange objectForKey:@"min"] toUnit:unitName];
    NSNumber * maxValue = [currentUnit convertValue:[unitRange objectForKey:@"max"] toUnit:unitName];
    [unitRange setValue:minValue forKey:@"min"];
    [unitRange setValue:maxValue forKey:@"max"];

    // Now convert this unit to the new one
    currentUnit = [currentUnit convertTo:unitName];

    // Set the new range
    [self setRange];
    
    // New value
    [self updateSliderValue : [[currentUnit getValue] floatValue]];
    
    // Update the unit of measurement
    [unitField setTitle:[currentUnit getAbbr] forState:UIControlStateNormal];
}


// Save Action
- (IBAction) save: (id) sender
{
    // Convert the value to the expected unit
    NSString * stringValue;
    if ([nameTextField isHidden])
    {
        float value = [[currentUnit getBaseValue] floatValue];
        stringValue = [NSString stringWithFormat:@"%1.3f", value];
    }
    else
    {
        stringValue = [nameTextField text];
    }
    
    // Pass current value to the edited object
    [self.editedObject setValue:stringValue forKey:self.editedFieldKey];

    // Save
    RootViewController * controller = (RootViewController *) self.navigationController;
    [controller didFinishWithSave : YES];
    
    // Pop.
    [self.navigationController popViewControllerAnimated:YES];
}

// Cancel Action
- (IBAction) cancel:(id)sender
{
    // Don't pass current value to the edited object. Just pop.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
