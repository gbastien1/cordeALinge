
#include "glUtil.h"
#import <Foundation/Foundation.h>

class CMesh;
class CSkyBox;


@interface CRenderer : NSObject {
	
    @public
    GLfloat rotx, roty, rotz;
    GLfloat camposx, camposy, camposz;
}



-(id) init;
-(void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height;
-(void) render:(CMesh*)mesh:(int)type; //AL If type == 0, Render normally. if 1, Render using GL_LINES. if 2, Render using Wave Shader
-(void) dealloc;
-(void) incr_rot:(float)dx :(float)dy :(float)dz;
-(void) incr_camposz:(float)dz;

// Variables uniforms
-(void) set_diffuse_contrib:(float)val;
-(void) set_ambiant_contrib:(float)val;
-(void) set_spec_contrib:(float)val;
-(void) set_mat_shininess:(float)val;
-(void) set_time:(float)val;
-(void) set_angle:(float)val;
-(void) set_amplitude:(float)val;
-(void) set_frequence:(float)val;
-(void) set_vitesse:(float)val;

@end
