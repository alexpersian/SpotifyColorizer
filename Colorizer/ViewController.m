//
//  ViewController.m
//  Colorizer
//
//  Created by Alex Persian on 2/6/20.
//  Copyright © 2020 Alex Persian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (nonatomic) UIImagePickerController *imagePicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = NO;
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    _photoImageView.image = [UIImage imageNamed:@"SpotifyLogoBlack"];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    if ([info valueForKey:UIImagePickerControllerOriginalImage] != NULL) {
        UIImage *pickedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        _photoImageView.image = pickedImage;
    } else {
        NSLog(@"Error: Unable to find original image.");
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)tappedSelectPhoto:(id)sender {
    NSLog(@"Opening image picker...");
    [self presentViewController:_imagePicker animated:YES completion:NULL];
}

- (IBAction)tappedColorize:(id)sender {
    NSLog(@"Colorizing...");

    // Grey scale the image

    // Apply color overlay to image

    // Display image back into image view
    
}

@end
