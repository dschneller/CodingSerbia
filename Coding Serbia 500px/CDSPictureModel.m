//
//  CDSPictureModel.m
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 12.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import "CDSPictureModel.h"

#define CACHE_SIZE_MB 5

@implementation CDSPictureModel
{
    // private instance variables to store small
    // values after their first retrieval. Because the
    // properties are declared readonly in the .h file,
    // these variables are not automatically generated.
    
    UIImage* _thumbnail;
    NSNumber* _filesize;
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

-(UIImage *)thumbnail
{
    if (!_thumbnail)
    {
        UIImage* image = self.image;
        CGSize thumbnailSize = CGSizeMake(43, 43);
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _thumbnail = newImage;
    }
    return _thumbnail;
}

-(UIImage*)image
{
    UIImage* image = [[CDSPictureModel imageCache] objectForKey:self.filepath];
    if (image)
    {
        return image;
    }
    
    image = [UIImage imageWithContentsOfFile:self.filepath];
    [[CDSPictureModel imageCache] setObject:image
                                     forKey:self.filepath
                                       cost:[self.filesize unsignedIntegerValue]];
    
    return image;
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

@end
