
#include "glUtil.h"
#import <Foundation/Foundation.h>

class CMesh;
class CSkyBox;


@interface CRenderer : NSObject {
	
    @public
    float rotx, roty, rotz;
    GLfloat camposx, camposy, camposz;
}



-(id) init;
-(void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height;
-(void) render:(CMesh*)mesh;
-(void) dealloc;
-(void)incr_rot:(float)dx :(float)dy :(float)dz;
-(void)incr_camposz:(float)dz;
-(void) reinitializeCamTransformations;

// Variables uniforms
-(void)set_diffuse_contrib:(float)val;
-(void)set_ambiant_contrib:(float)val;
-(void)set_spec_contrib:(float)val;
-(void)set_mat_shininess:(float)val;


/*
void setRotx(GLfloat rx);
void setRoty(GLfloat ry);
void setRotz(GLfloat rz);
void setCamposx(GLfloat cx);
void setCamposy(GLfloat cy);
void setCamposz(GLfloat cz);

GLfloat getRotx();
GLfloat getRoty();
GLfloat getRotz();
GLfloat getCamposx();
GLfloat getCamposy();
GLfloat getCamposz();
*/

@end
