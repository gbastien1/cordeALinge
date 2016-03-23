#pragma once

#include "glutil.h"

typedef struct shader_source_data
{
	GLchar* string;
	GLsizei byteSize;
	GLenum shader_type; // Vertex or Fragment
	
} shader_source_data;

shader_source_data* shader_source_load(const char* filepathname);
void shader_source_destroy(shader_source_data* source);
