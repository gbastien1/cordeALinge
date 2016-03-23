//
//  glutils.cpp
//  gl-proto
//
//  Created by ychirico on 2014-12-13.
//
//

#include "glutil.h"


// Utilile avec OpenGLProfiler pour forcer un break sur erreur.
void break_debug()
{
    //asm( "int $0x03;");
    glBindTexture(-1, 0);
}


void shader_setuniform(const GLuint program, const char* name, const int val)
{
    GLuint loc = glGetUniformLocation(program, name);
    glUniform1i(loc, val);
}

