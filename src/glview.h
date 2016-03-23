
#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>


#import "imageutil.h"

class CMesh;
@class CRenderer;

// Bien que pas dans la vue en tant que tel, c'est dans cette classe que 
// sont contenus les contrôles de la fenêtre. C'est plus pratique vue 
// qu'elle contient aussi le mesh et le renderer.

@interface CGLView : NSOpenGLView {
	CVDisplayLinkRef display_link;
    
    float mouse_x0, mouse_y0;
    
    CMesh*      mesh;
    CRenderer*  renderer;
    NSTimer*    frame_timer;
}


@property (assign) IBOutlet NSSlider*     sl_diffuse_contrib;
@property (assign) IBOutlet NSSlider*     sl_ambiant_contrib;
@property (assign) IBOutlet NSSlider*     sl_spec_contrib;
@property (assign) IBOutlet NSSlider*     sl_mat_shininess;
@property (assign) IBOutlet NSButton*     bt_load_mesh;
@property (assign) IBOutlet NSButton*     bt_load_image;
@property (assign) IBOutlet NSButton*     bt_start;
@property (assign) IBOutlet NSButton*     bt_stop;


-(IBAction)bt_load_mesh_pressed:(NSButton*)sender;
-(IBAction)bt_load_image_pressed:(NSButton*)sender;
-(IBAction)bt_start_pressed:(NSButton*)sender;
-(IBAction)bt_stop_pressed:(NSButton*)sender;

// Lecture d'un fichier en format ply.
-(void)load_mesh:(const char*)fply;


@end
