#pragma once

#include "glutil.h"

typedef struct image_data {
	GLubyte* data;
	
	GLsizei size;
	
	GLuint width;
	GLuint height;
	GLenum format;
	GLenum type;
	
	GLuint rowByteSize;
	
} image_data;

image_data* image_load(const char* filepathname, int flip_vertical);

void image_destroy(image_data* image);

void* alloc_pixels_from_file(const char* file, unsigned int& height, unsigned int& width);
GLuint  gl_load_texture2D(const char* file);
void    gl_load_texture_cube_map_side(const char* file, GLuint target_side/*, GLuint texid*/);
