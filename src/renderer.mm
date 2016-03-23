
#import "renderer.h"
#import "matrixUtil.h"
#import "imageUtil.h"
#import "sourceUtil.h"
#include "mesh.h"


#include <iostream>

using namespace std;

static void display_ogl_version()
{
    const GLubyte *renderer = glGetString( GL_RENDERER );
    const GLubyte *vendor = glGetString( GL_VENDOR );
    const GLubyte *version = glGetString( GL_VERSION );
    const GLubyte *glslVersion = glGetString( GL_SHADING_LANGUAGE_VERSION );
    
    GLint major, minor;
    glGetIntegerv(GL_MAJOR_VERSION, &major);
    glGetIntegerv(GL_MINOR_VERSION, &minor);
    
    printf("GL Vendor    : %s\n", vendor);
    printf("GL Renderer  : %s\n", renderer);
    printf("GL Version   : %s\n", version);
    printf("GL Version   : %d.%d\n", major, minor);
    printf("GLSL Version : %s\n", glslVersion);
        

    GLint nExtensions;
    glGetIntegerv(GL_NUM_EXTENSIONS, &nExtensions);
    for( int i = 0; i < nExtensions; i++ ) 
    {
        printf("%s\n", glGetStringi(GL_EXTENSIONS, i));
    }
    
    printf("\n");
}

enum {
	POS_ATTRIB_IDX,
	COLOR_ATTRIB_IDX,
	TEXCOORD_ATTRIB_IDX
};

#ifndef NULL
#define NULL 0
#endif


@implementation CRenderer

// Variable globales (c'est pas idéal, mais c'est un prototype).
GLuint shader_prog_name;
GLint uniform_mvp_matrix_idx;
GLint uniform_model_view_matrix_idx;
GLint uniform_normal_matrix_idx;

GLfloat light_pos[] = {0.0, 30.0, 30.0};
GLfloat mat_ambiant[] = {0.2, 0.2, 0.2};
GLfloat mat_diffuse[] = {0.2, 0.2, 0.2};


GLuint view_width;
GLuint view_height;

GLfloat rotx = 0.0, roty = 0.0, rotz = 0.0, camposz = -10.0;

// Incrémente les angles.
-(void)incr_rot:(float)dx :(float)dy :(float)dz
{
    rotx += dx;
    if (rotx > 360.0)
        rotx -= 360.0;
    else if (rotx < -360.0)
        rotx += 360.0;
    
    roty += dy;
    if (roty > 360.0)
        roty -= 360.0;
    else if (roty < -360.0)
        roty += 360.0;
    
    rotz += dz;
    if (rotz > 360.0)
        rotz -= 360.0;
    else if (rotz < -360.0)
        rotz += 360.0;
}

-(void)incr_camposz:(float)z
{
    camposz += z;
}


- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height
{
	glViewport(0, 0, width, height);

	view_width = width;
	view_height = height;
}


-(GLuint) build_prog:(shader_source_data*)vertex_src with_fragment_src:(shader_source_data*)fragment_src
{
	GLuint prog_name;
	GLint log_length, status;
	GLchar* src_string = NULL;
	
    GetGLError();
    
	prog_name = glCreateProgram();
			
	src_string = (char*)malloc(vertex_src->byteSize + 1/*version_str_size*/);
	sprintf(src_string, /*"#version %d\n%s", version,*/ vertex_src->string);
			
	GLuint vertex_shader = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertex_shader, 1, (const GLchar **)&(src_string), NULL);
	glCompileShader(vertex_shader);
	glGetShaderiv(vertex_shader, GL_INFO_LOG_LENGTH, &log_length);
	
	if (log_length > 0) 
	{
		GLchar *log = (GLchar*) malloc(log_length);
		glGetShaderInfoLog(vertex_shader, log_length, &log_length, log);
		NSLog(@"Vtx Shader compile log:%s\n", log);
		free(log);
	}
	
	glGetShaderiv(vertex_shader, GL_COMPILE_STATUS, &status);
	if (status == 0)
	{
		NSLog(@"Failed to compile vtx shader:\n%s\n", src_string);
		return 0;
	}
	
	free(src_string);
	src_string = NULL;
	
	glAttachShader(prog_name, vertex_shader);
	glDeleteShader(vertex_shader);
	src_string = (char*)malloc(fragment_src->byteSize + 1/*version_str_size*/);
	sprintf(src_string, /*"#version %d\n%s", version, */fragment_src->string);
	
	GLuint frag_shader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(frag_shader, 1, (const GLchar **)&(src_string), NULL);
	glCompileShader(frag_shader);
	glGetShaderiv(frag_shader, GL_INFO_LOG_LENGTH, &log_length);
	if (log_length > 0) 
	{
		GLchar *log = (GLchar*)malloc(log_length);
		glGetShaderInfoLog(frag_shader, log_length, &log_length, log);
		NSLog(@"Frag Shader compile log:\n%s\n", log);
		free(log);
	}
	
	glGetShaderiv(frag_shader, GL_COMPILE_STATUS, &status);
	if (status == 0)
	{
		NSLog(@"Failed to compile frag shader:\n%s\n", src_string);
		return 0;
	}
	
	free(src_string);
	src_string = NULL;
	
	glAttachShader(prog_name, frag_shader);
	glDeleteShader(frag_shader);
	glLinkProgram(prog_name);
	glGetProgramiv(prog_name, GL_INFO_LOG_LENGTH, &log_length);
	if (log_length > 0)
	{
		GLchar *log = (GLchar*)malloc(log_length);
		glGetProgramInfoLog(prog_name, log_length, &log_length, log);
		NSLog(@"Program link log:\n%s\n", log);
		free(log);
	}
	
	glGetProgramiv(prog_name, GL_LINK_STATUS, &status);
	if (status == 0)
	{
		NSLog(@"Failed to link program");
		return 0;
	}
	
    GetGLError();
    
    
#if 0	
    glValidateProgram(prog_name);
	glGetProgramiv(prog_name, GL_INFO_LOG_LENGTH, &log_length);
	if (log_length > 0)
	{
		GLchar *log = (GLchar*)malloc(log_length);
		glGetProgramInfoLog(prog_name, log_length, &log_length, log);
		NSLog(@"Program validate log:\n%s\n", log);
		free(log);
	}
	
	glGetProgramiv(prog_name, GL_VALIDATE_STATUS, &status);
	if (status == 0)
	{
		NSLog(@"Failed to validate program");
		return 0;
	}
	
	GetGLError();
#endif
	return prog_name;
}

- (id) init
{
	if((self = [super init]))
	{
#if 0
        display_ogl_version();
		NSLog(@"%s %s", glGetString(GL_RENDERER), glGetString(GL_VERSION));
#endif		
		view_width = 100;
		view_height = 100;
		
		NSString* file_path_name = nil;
		
        shader_source_data *vtxSource = NULL;
		shader_source_data *frgSource = NULL;
		
		file_path_name = [[NSBundle mainBundle] pathForResource:@"generic" ofType:@"vsh"];
		vtxSource = shader_source_load([file_path_name cStringUsingEncoding:NSASCIIStringEncoding]);
		
		file_path_name = [[NSBundle mainBundle] pathForResource:@"generic" ofType:@"fsh"];
		frgSource = shader_source_load([file_path_name cStringUsingEncoding:NSASCIIStringEncoding]);
		
		shader_prog_name = [self build_prog:vtxSource with_fragment_src:frgSource];

        glUseProgram(shader_prog_name);
        GLuint loc = glGetUniformLocation(shader_prog_name, "tex_diffuse");
        glUniform1i(loc, 0);
        
        uniform_mvp_matrix_idx = glGetUniformLocation(shader_prog_name, "modelview_proj_matrix");
        uniform_model_view_matrix_idx = glGetUniformLocation(shader_prog_name, "modelview_matrix");
        uniform_normal_matrix_idx = glGetUniformLocation(shader_prog_name, "normal_matrix");

        shader_source_destroy(vtxSource);
        shader_source_destroy(frgSource);

		glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
		
		
 	}
	
	return self;
}

-(void)delete_ogl_objects
{
    // PATCH: Effacer les ressources ogl ici.
	//glDeleteTextures(1, &tex_name);
    glDeleteProgram(shader_prog_name);
}

- (void) dealloc
{
	[self delete_ogl_objects];
	[super dealloc];	
}




-(void)set_diffuse_contrib:(float)val
{
    glUseProgram(shader_prog_name);
    GLuint loc = glGetUniformLocation(shader_prog_name, "diffuse_contrib");
    glUniform1f(loc, val);
}

-(void)set_ambiant_contrib:(float)val
{
    GLuint loc = glGetUniformLocation(shader_prog_name, "ambiant_contrib");
    glUniform1f(loc, val);
}

-(void)set_spec_contrib:(float)val
{
    glUseProgram(shader_prog_name);
    GLuint loc = glGetUniformLocation(shader_prog_name, "spec_contrib");
    glUniform1f(loc, val);
}

-(void)set_mat_shininess:(float)val
{
    glUseProgram(shader_prog_name);
    GLuint loc = glGetUniformLocation(shader_prog_name, "mat_shininess");
    glUniform1f(loc, val);
}



- (void)render:(CMesh*)mesh
{
    GLfloat viewdir_matrix[16];        // Matrice sans la translation (pour le cube map et le skybox).
    GLfloat model_view_matrix[16];
    GLfloat projection_matrix[16];
    GLfloat normal_matrix[9];    
    GLfloat mvp_matrix[16];
    GLfloat vp_matrix[16];
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    mtxLoadPerspective(projection_matrix, 50, (float)view_width/ (float)view_height, 1.0, 100.0);
    mtxLoadTranslate(model_view_matrix, 0, 0.0, camposz);
    mtxRotateXApply(model_view_matrix, rotx);
    mtxRotateYApply(model_view_matrix, roty);
    mtxRotateZApply(model_view_matrix, rotz);
    
    mtxLoadIdentity(viewdir_matrix);
    mtxRotateXApply(viewdir_matrix, rotx);
    mtxRotateYApply(viewdir_matrix, roty);
    mtxRotateZApply(viewdir_matrix, rotz);
    
    mtxMultiply(mvp_matrix, projection_matrix, model_view_matrix);
    mtxMultiply(vp_matrix, projection_matrix, viewdir_matrix);
    
    
    mtx3x3FromTopLeftOf4x4(normal_matrix, model_view_matrix);
    mtx3x3Invert(normal_matrix, normal_matrix);

    
    if ( mesh )
    {
        glUseProgram(shader_prog_name);
        
        glUniformMatrix4fv(uniform_mvp_matrix_idx, 1, GL_FALSE, mvp_matrix);
        glUniformMatrix4fv(uniform_model_view_matrix_idx, 1, GL_FALSE, model_view_matrix);
        glUniformMatrix3fv(uniform_normal_matrix_idx, 1, GL_FALSE, normal_matrix);
        //glUniformMatrix3fv(uniform_viewdir_matrix_idx, 1, GL_FALSE, viewdir_matrix);
        glUniformMatrix4fv(uniform_mvp_matrix_idx, 1, GL_FALSE, mvp_matrix);
        
        GLuint loc = glGetUniformLocation(shader_prog_name, "light_pos");
        glUniform3f(loc, light_pos[0], light_pos[1], light_pos[2]);
        
        loc = glGetUniformLocation(shader_prog_name, "cam_pos");
        glUniform3f(loc, normal_matrix[6], normal_matrix[7], normal_matrix[8]);
        
        mesh->Draw(shader_prog_name);
    }
}



@end
