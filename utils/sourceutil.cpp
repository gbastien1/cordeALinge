

#include "sourceutil.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

shader_source_data* shader_source_load(const char* filepathname)
{
	shader_source_data* source = (shader_source_data*) calloc(sizeof(shader_source_data), 1);
	
	// Check the file name suffix to determine what type of shader this is
	const char* suffixBegin = filepathname + strlen(filepathname) - 4;
	
	if(0 == strncmp(suffixBegin, ".fsh", 4))
	{
		source->shader_type = GL_FRAGMENT_SHADER;
	}
	else if(0 == strncmp(suffixBegin, ".vsh", 4))
	{
		source->shader_type = GL_VERTEX_SHADER;
	}
	else
	{
		// Unknown suffix
		source->shader_type = 0;
	}
	
	FILE* curFile = fopen(filepathname, "r");
	
	// Get the size of the source
	fseek(curFile, 0, SEEK_END);
	GLsizei fileSize = ftell (curFile);
	
	// Add 1 to the file size to include the null terminator for the string
	source->byteSize = fileSize + 1;
	
	// Alloc memory for the string
	source->string = (char*)malloc(source->byteSize);
	
	// Read entire file into the string from beginning of the file
	fseek(curFile, 0, SEEK_SET);
	fread(source->string, 1, fileSize, curFile);
	
	fclose(curFile);
	
	// Insert null terminator
	source->string[fileSize] = 0;
	
	return source;
}

void shader_source_destroy(shader_source_data* source)
{
	free(source->string);
	free(source);
}