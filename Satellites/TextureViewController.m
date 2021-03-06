//
//  TextureViewController.m
//  Satellites
//
//  Created by Richard Benjamin Heidorn on 8/21/13.
//  Copyright (c) 2013 Richard B Heidorn. All rights reserved.
//

#import "TextureViewController.h"

@implementation TextureViewController

@synthesize editedObject;
@synthesize albums;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    
    [self.collectionView registerClass: [TextureCollectionViewCell class] forCellWithReuseIdentifier: @"TextureCell"];
    
    // Populate the albums
    [self populateAlbums];
}

- (void) populateAlbums
{
    // Instantiate the albums collection
    self.albums = [NSMutableArray array];
    
    // Iterate through the folder of textures
    NSError       * error       = nil;
    NSFileManager * fileManager = [[NSFileManager alloc] init];
    
    // Get the path to the images, then retrieve the images
    NSString      * bundlePath   = [[NSBundle mainBundle] bundlePath];
    NSString      * texturesPath = [bundlePath stringByAppendingString:@"/Textures/"];
    NSArray       * files        = [fileManager contentsOfDirectoryAtPath:texturesPath error:&error];
    
    // If there are no files, handle the error.. eventually.
    if (files == nil)
    {
        // Handle error here.
    }
    
    // Prepare the album
    NSMutableArray * album;
    
    // Add each item to the list
    for (NSString * file in files)
    {
        album = [[NSMutableArray alloc] init];
        [album addObject:[texturesPath stringByAppendingString:file]];
        [self.albums addObject:album];
    }
    
    // Add the album to the collection
    //[self.albums addObject:album];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the image at this location
    NSString * imageUrl = self.albums[indexPath.section][indexPath.row];

    // Parse the image URL for the only necessary information
    NSArray * urlComponents;
    urlComponents = [imageUrl componentsSeparatedByString:@"/"];
    imageUrl      = [urlComponents lastObject];
    urlComponents = [imageUrl componentsSeparatedByString:@"."];
    imageUrl      = [urlComponents objectAtIndex:0];

    // Pass current value to the edited object
    [self.editedObject setValue:imageUrl forKey:@"texture"];
    
    // Save
    RootViewController * controller = (RootViewController *) self.navigationController;
    [controller didFinishWithSave : YES];
    
    // Pop.
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Return the total number of albums
    return self.albums.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Return the number of textures in this album
    //NSMutableArray * album = self.albums[section];
    //return album.count;
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TextureCollectionViewCell * photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TextureCell" forIndexPath: indexPath];
    
    // Get the image url from the album
    NSString * imageUrl = self.albums[indexPath.section][indexPath.row];
    
    // Ensure we have an image
    if (!imageUrl)
    {
        return photoCell;
    }
    
    // Get and set the image
    UIImage  * image = [UIImage imageWithContentsOfFile:imageUrl];
    photoCell.imageView.image = image;
    return photoCell;
}

#pragma mark - View Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.textureViewLayout.numberOfColumns = 3;
        
        // handle insets for iPhone 4 or 5
        CGFloat sideInset = [UIScreen mainScreen].preferredMode.size.width == 1136.0f ? 45.0f : 25.0f;
        
        self.textureViewLayout.itemInsets = UIEdgeInsetsMake(22.0f, sideInset, 13.0f, sideInset);
        
    }
    else
    {
        self.textureViewLayout.numberOfColumns = 2;
        self.textureViewLayout.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
