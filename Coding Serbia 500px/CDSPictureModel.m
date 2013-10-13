//
//  CDSPictureModel.m
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 12.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import "CDSPictureModel.h"
#import "UIImage+CDSThumbnail.h"
#import <ImageIO/ImageIO.h>

#define CACHE_SIZE_MB 1

@implementation CDSPictureModel
{
    // private instance variables to store small
    // values after their first retrieval. Because the
    // properties are declared readonly in the .h file,
    // these variables are not automatically generated.
    
    UIImage* _thumbnail;
    NSNumber* _filesize;
    CGFloat _exposureTime;
    NSString* _resolution;
    NSDate* _shotDate;
    
    BOOL _didReadExif;
}

+ (NSCache*) imageCache
{
    static NSCache* imageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [[NSCache alloc] init];
        [imageCache setTotalCostLimit:CACHE_SIZE_MB * 1024L * 1024L];
    });
    return imageCache;
}

- (id)initWithPath:(NSString*)path
{
    self = [super init];
    if (self) {
        _filepath = path;
    }
    return self;
}

- (void)prepareThumbnail
{
    if (!_thumbnail)
    {
        UIImage* image = self.image;
        [self prepareThumbnailFor:image];
        [self readExifData];
    }
}

- (void)prepareThumbnailFor:(UIImage*)image
{
    if (!image) return;
    [NSThread sleepForTimeInterval:1.0];
    _thumbnail = [image generateThumbail];
    
    __weak CDSPictureModel* weakModel = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CDSPictureModel* strongSelf = weakModel;
        if (!strongSelf) return;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ThumbnailDidUpdateNotification" object:strongSelf userInfo:nil];
    });

}

- (CGFloat)exposureTime
{
    if (!_didReadExif) { [self readExifData]; }
    return _exposureTime;
}

- (NSString *)resolution
{
    if (!_didReadExif) { [self readExifData]; }
    return _resolution;
}

- (NSDate *)shotDate
{
    if (!_didReadExif) { [self readExifData]; }
    return _shotDate;
}

-(UIImage *)thumbnail
{
    __weak CDSPictureModel* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CDSPictureModel* strongSelf = weakSelf;
        if (!strongSelf) { return; }
        [strongSelf prepareThumbnail];;
    });
    return _thumbnail;
}

-(UIImage*)image
{
    __block UIImage* image = [[CDSPictureModel imageCache] objectForKey:self.filepath];
    if (image)
    {
        return image;
    }
    else
    {
        __weak CDSPictureModel* weakModel = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CDSPictureModel* strongSelf = weakModel;
            if (!strongSelf) return;
            image = [UIImage imageWithContentsOfFile:strongSelf.filepath];
            [[CDSPictureModel imageCache] setObject:image
                                             forKey:strongSelf.filepath
                                               cost:[strongSelf.filesize unsignedIntegerValue]];
            [strongSelf prepareThumbnailFor:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageRetrieved" object:strongSelf userInfo:@{@"img" : image}];
            });
        });
        return nil;
    }
}

-(NSNumber*)filesize
{
    if (! _filesize)
    {
        NSError* error = nil;
        NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filepath error:&error];
        if (error)
        {
            NSLog(@"Could not determine files size for %@: %@", self.filepath, error);
            return nil;
        }
        _filesize = fileAttributes[NSFileSize];
    }
    return _filesize;
}

- (void) readExifData
{
    if (_didReadExif) return;
    
    NSURL* url = [NSURL fileURLWithPath:self.filepath];
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url , NULL);
    
    CFDictionaryRef imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    
    // Image Dimensions
    // -----------------------------
    CFNumberRef imageWidth = (CFNumberRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyPixelWidth);
    CFNumberRef imageHeight = (CFNumberRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyPixelHeight);
    int w = 0;
    int h = 0;
    CFNumberGetValue(imageWidth, kCFNumberIntType, &w);
    CFNumberGetValue(imageHeight, kCFNumberIntType, &h);
    _resolution = [NSString stringWithFormat:@"%dx%d", w, h];

    
    // EXIF DATA
    // -----------------------------
    CFDictionaryRef exif = (CFDictionaryRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyExifDictionary);
    
    // Shot Date
    NSString* shotDate = CFDictionaryGetValue(exif, kCGImagePropertyExifDateTimeOriginal);
    NSDateFormatter* f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy:mm:dd HH:MM:ss"];
    _shotDate = [f dateFromString:shotDate];
    
    NSString* exposure = CFDictionaryGetValue(exif, kCGImagePropertyExifExposureTime);
    _exposureTime = [exposure floatValue];
    
    CFRelease(imagePropertiesDictionary);
    CFRelease(source);
    
    _didReadExif = YES;
}

@end
