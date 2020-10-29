// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from ImageProcessor.djinni

#import <Foundation/Foundation.h>
@class DKImageProcessor;


@interface DKImageProcessor : NSObject

/**
 * `create()` factory method has to be used to create an instance of the class in Swift/Objective-C/Kotlin/Java
 *
 * For example, in Swift:
 * let wrapper = DKImageProcessor.create()!
 *
 * in Objective-C:
 * DKImageProcessor *wrapper = [DKImageProcessor create];
 */
+ (nullable DKImageProcessor *)create;

- (BOOL)processRGBAImage:(int32_t)width
                  height:(int32_t)height
                   bytes:(nonnull NSData *)bytes;

- (nonnull NSData *)processRGBAImageAndRenderOverlay:(int32_t)width
                                              height:(int32_t)height
                                               bytes:(nonnull NSData *)bytes;

- (nonnull NSData *)processAndAugmentRGBAImage:(int32_t)width
                                        height:(int32_t)height
                                         bytes:(nonnull NSData *)bytes;

- (nonnull NSString *)readJson;

- (BOOL)isFinished;

- (nonnull NSData *)getFaceImage:(int32_t)faceIndex
                          height:(int32_t)height
                           bytes:(nonnull NSData *)bytes;

@end
