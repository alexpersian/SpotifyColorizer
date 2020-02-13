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
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorPicker;

@property (nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic) UIImage *selectedImage;
@property (nonatomic) CIColor *lightColor;
@property (nonatomic) CIColor *darkColor;

- (IBAction)savePhoto:(UIGestureRecognizer *)gestureRecognizer;
- (IBAction)colorSegmentChanged:(id)sender;
- (IBAction)tappedSelectPhoto:(id)sender;
- (IBAction)tappedColorize:(id)sender;

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

    _selectPhotoButton.layer.cornerRadius = 8.0f;
    _colorizeButton.layer.cornerRadius = 8.0f;

    _lightColor = [[CIColor alloc] initWithRed:0.33 green:0.98 blue:0.25 alpha:1.0];
    _darkColor = [[CIColor alloc] initWithRed:0.09 green:0.14 blue:0.32 alpha:1.0];

    [_selectPhotoButton addTarget:self
                           action:@selector(tappedSelectPhoto:)
                 forControlEvents:UIControlEventTouchUpInside];
    [_colorizeButton addTarget:self
                        action:@selector(tappedColorize:)
              forControlEvents:UIControlEventTouchUpInside];
    [_colorPicker addTarget:self
                     action:@selector(colorSegmentChanged:)
           forControlEvents:UIControlEventValueChanged];

    UIGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(savePhoto:)];
    [_photoImageView addGestureRecognizer:longPress];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *pickedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (pickedImage != NULL) {
        _selectedImage = pickedImage;
        _photoImageView.image = pickedImage;
    } else {
        NSLog(@"Error: Unable to access image.");
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)savePhoto:(UIGestureRecognizer*)gesture {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NULL
                                                                   message:NULL
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Save Photo"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        UIImageWriteToSavedPhotosAlbum(self->_photoImageView.image, NULL, NULL, NULL);
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [alert addAction:cancelAction];

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self presentViewController:alert animated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (IBAction)colorSegmentChanged:(id)sender {
    switch (_colorPicker.selectedSegmentIndex) {
        case 0:
            // Green and navy
            _lightColor = [[CIColor alloc] initWithRed:0.33 green:0.98 blue:0.25 alpha:1.0];
            _darkColor = [[CIColor alloc] initWithRed:0.09 green:0.14 blue:0.32 alpha:1.0];
            break;
        case 1:
            // Red and navy
            _lightColor = [[CIColor alloc] initWithRed:0.89 green:0.00 blue:0.15 alpha:1.0];
            _darkColor = [[CIColor alloc] initWithRed:0.09 green:0.14 blue:0.32 alpha:1.0];
            break;
        case 2:
            // Blue and scarlet
            _lightColor = [[CIColor alloc] initWithRed:0.55 green:0.94 blue:0.85 alpha:1.0];
            _darkColor = [[CIColor alloc] initWithRed:0.47 green:0.04 blue:0.15 alpha:1.0];
            break;
        case 3:
            // Yellow and navy
            _lightColor = [[CIColor alloc] initWithRed:0.95 green:0.90 blue:0.13 alpha:1.0];
            _darkColor = [[CIColor alloc] initWithRed:0.09 green:0.14 blue:0.32 alpha:1.0];
            break;
        default:
            break;
    }
}

- (IBAction)tappedSelectPhoto:(id)sender {
    [self presentViewController:_imagePicker animated:YES completion:NULL];
}

- (IBAction)tappedColorize:(id)sender {
    // Store the original orientation and scale to reapply it to the CGImage below.
    // If we don't do this then the output image may be rotated or scaled incorrectly.
    UIImageOrientation originalOrientation = _selectedImage.imageOrientation;
    CGFloat originalScale = _selectedImage.scale;

    CIContext *context = [[CIContext alloc] initWithOptions:NULL];

    // MARK: Grayscale Filter
    CIFilter *grayscaleFilter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    [grayscaleFilter setValue:[CIImage imageWithCGImage:_selectedImage.CGImage]
                       forKey:kCIInputImageKey];

    // MARK: Multiply filter
    CIFilter *multiplyFilter = [CIFilter filterWithName:@"CIMultiplyBlendMode"];
    CIImage *multiColorImage = [CIImage imageWithColor:_lightColor];
    [multiplyFilter setValue:grayscaleFilter.outputImage
                      forKey:kCIInputImageKey];
    [multiplyFilter setValue:multiColorImage
                      forKey:kCIInputBackgroundImageKey];

    // MARK: Lighten filter
    CIFilter *lightenFilter = [CIFilter filterWithName:@"CILightenBlendMode"];
    CIImage *colorImage = [CIImage imageWithColor:_darkColor];
    [lightenFilter setValue:multiplyFilter.outputImage
                     forKey:kCIInputImageKey];
    [lightenFilter setValue:colorImage
                     forKey:kCIInputBackgroundImageKey];

    // Rect for final image is provided by the grayscale image since the solid-color
    // images generated at the multiply and lighten steps are of infinite size.
    // https://developer.apple.com/documentation/coreimage/ciimage/1547012-imagewithcolor
    struct CGImage *cgi = [context createCGImage:lightenFilter.outputImage
                                        fromRect:grayscaleFilter.outputImage.extent];

    // Update the imageview with the new image with filters applied. Ensuring that original
    // orientation and scale are respected.
    _photoImageView.image = [UIImage imageWithCGImage:cgi
                                                scale:originalScale
                                          orientation:originalOrientation];
}

@end
