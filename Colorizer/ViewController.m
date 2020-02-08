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
@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *colorizeButton;
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
    _photoImageView.image = [UIImage imageNamed:@"colin"];

    _selectPhotoButton.layer.cornerRadius = 8.0f;
    _colorizeButton.layer.cornerRadius = 8.0f;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    if ([info valueForKey:UIImagePickerControllerOriginalImage] != NULL) {
        UIImage *pickedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        _photoImageView.image = pickedImage;
    } else {
        NSLog(@"Error: Unable to access image.");
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)tappedSelectPhoto:(id)sender {
    NSLog(@"Opening image picker...");
    [self presentViewController:_imagePicker animated:YES completion:NULL];
}

- (IBAction)tappedColorize:(id)sender {
    NSLog(@"Colorizing...");

    CIContext *context = [[CIContext alloc] initWithOptions:NULL];

    CIColor *lightColor = [[CIColor alloc] initWithRed:0
                                                 green:1.0
                                                  blue:0.21
                                                 alpha:1.0];

    CIColor *darkColor = [[CIColor alloc] initWithRed:0.14
                                                green:0.15
                                                 blue:0.54
                                                alpha:1.0];

    // MARK: Grayscale Filter
    CIFilter *grayscaleFilter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    [grayscaleFilter setValue:[CIImage imageWithCGImage:_photoImageView.image.CGImage]
                       forKey:kCIInputImageKey];

    // MARK: Multiply filter
    CIFilter *multiplyFilter = [CIFilter filterWithName:@"CIMultiplyBlendMode"];

    CIImage *multiColorImage = [CIImage imageWithColor:lightColor];
    [multiplyFilter setValue:grayscaleFilter.outputImage
                     forKey:@"inputImage"];
    [multiplyFilter setValue:multiColorImage
                     forKey:@"inputBackgroundImage"];

    // MARK: Lighten filter
    CIFilter *lightenFilter = [CIFilter filterWithName:@"CILightenBlendMode"];

    CIImage *colorImage = [CIImage imageWithColor:darkColor];
    [lightenFilter setValue:multiplyFilter.outputImage
                     forKey:@"inputImage"];
    [lightenFilter setValue:colorImage
                     forKey:@"inputBackgroundImage"];

    // Rect for final image is provided by monochrome image since the color-based
    // image generated at the lighten step is of infinite size.
    struct CGImage *cgi = [context createCGImage:lightenFilter.outputImage
                                        fromRect:grayscaleFilter.outputImage.extent];

    // Update the imageview with the newly filtered image.
    _photoImageView.image = [UIImage imageWithCGImage:cgi];
}

@end
