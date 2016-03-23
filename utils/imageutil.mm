
#include "imageutil.h"
#include <iostream>
#import <Cocoa/Cocoa.h>
#include <OPENGL/gl3.h>

using namespace std;

// Allocation des pixels. Il faut les libérer (free()) lorsqu'on en a terminé.
void* alloc_pixels_from_file(const char* file, unsigned int& height, unsigned int& width)
{
    CFStringRef filename = CFStringCreateWithCString (kCFAllocatorDefault, file, kCFStringEncodingUTF8/*kCFStringEncodingASCII*/);
    CFURLRef  image_url = CFURLCreateWithFileSystemPath(NULL,
                                                        filename,
                                                        kCFURLPOSIXPathStyle,
                                                        false);
    CGDataProviderRef jpeg_provider = CGDataProviderCreateWithURL(image_url);
    if ( !jpeg_provider )
        return 0;
    
    CGImageRef image_ref = CGImageCreateWithJPEGDataProvider(jpeg_provider, 0, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(jpeg_provider);
    
    width = CGImageGetWidth(image_ref);
    height = CGImageGetHeight(image_ref);
    CGRect rect = {{0, 0}, {width, height}};
    void* pixels = calloc(4*width , height);
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef bm_context = CGBitmapContextCreate(pixels,
                                                    width, height, 8,
                                                    4*width, space,
                                                    kCGBitmapByteOrder32Host |
                                                    kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(bm_context, rect, image_ref);
    CGContextRelease(bm_context);

    return pixels;
}


// Retourne l'identificateur de la texture pour OpenGL.
GLuint gl_load_texture2D(const char* file)
{
    GLuint tex_name = 0;
    GLuint height, width;
    
    if ( !file )
        return 0;
    
    void* pixels = alloc_pixels_from_file(file, height, width);
    
    glGenTextures(1, &tex_name);
    glBindTexture(GL_TEXTURE_2D, tex_name);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, width);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height,
                 0, GL_BGRA, GL_UNSIGNED_BYTE, pixels);
    
    free(pixels);
    
    return tex_name;
}


void gl_load_texture_cube_map_side(const char* file, GLuint target_side/*, GLuint texid*/)
{
    GLuint height, width;

    if ( !file ) return;
    
    void* pixels = alloc_pixels_from_file(file, height, width);
    
    if ( !pixels )
    {
        cerr << "Unable to read file " << file << endl;
        return;
    }
    
    glTexImage2D(target_side, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, pixels);

    free(pixels);
}




void image_destroy(image_data* image)
{
	free(image->data);
	free(image);
}