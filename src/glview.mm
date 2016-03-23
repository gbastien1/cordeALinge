
#import "glview.h"
#import "renderer.h"

#include "mesh.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>

using namespace std;


static
NSArray* open_files(NSArray* filetype_ext)
{
    NSOpenPanel *panel;
    
    panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:filetype_ext];
    
    int i = [panel runModal];
    
    [panel hidesOnDeactivate];
    
    if (i == NSModalResponseOK)
    {
        return [panel URLs];
    }
    
    return nil;
}


@interface CGLView (PrivateMethods)
- (void) init_gl;

@end

@implementation CGLView

@synthesize sl_ambiant_contrib;
@synthesize sl_diffuse_contrib;
@synthesize sl_spec_contrib;
@synthesize sl_mat_shininess;
@synthesize bt_start;
@synthesize bt_stop;

-(void)load_mesh:(const char * )fply
{
    if ( mesh )
        delete mesh;
    
    mesh = new CMesh;
    
    ifstream f_in(fply);
    if ( !f_in.is_open() || !mesh->ReadPLY(f_in) )
        cerr << "Unable to read ply file" << endl;
    if ( f_in.is_open() )
        f_in.close();
    
#if 0
    //ofstream fout0("mesh0.txt", ios::out);
    cout << *mesh << endl;
    //fout0.close();
#endif
}

- (CVReturn) display_link_callback:(const CVTimeStamp*)outputTime
{
	// There is no autorelease pool when this method is called
	// because it will be called from a background thread.
	// It's important to create one or app can leak objects.
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[pool release];
	return kCVReturnSuccess;
}

static CVReturn display_link_callback(CVDisplayLinkRef display_link,
									  const CVTimeStamp* now,
									  const CVTimeStamp* outputTime,
									  CVOptionFlags flagsIn,
									  CVOptionFlags* flagsOut, 
									  void* display_link_context)
{
    CVReturn result = [(CGLView*)display_link_context display_link_callback:outputTime];
    return result;
}

- (void) awakeFromNib
{
    mesh = 0;
    frame_timer = 0;
    
    NSOpenGLPixelFormatAttribute attrs[] =
	{
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
#if ESSENTIAL_GL_PRACTICES_SUPPORT_GL3
		NSOpenGLPFAOpenGLProfile,
		NSOpenGLProfileVersion3_2Core,
#endif
		0
	};
	
	NSOpenGLPixelFormat *pf = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];
	
	if ( !pf )
	{
		NSLog(@"No OpenGL pixel format");
	}
	   
    NSOpenGLContext* context = [[[NSOpenGLContext alloc] initWithFormat:pf shareContext:nil] autorelease];
    
#if ESSENTIAL_GL_PRACTICES_SUPPORT_GL3 && defined(DEBUG)
	CGLEnable([context CGLContextObj], kCGLCECrashOnRemovedFunctions);
#endif
	
    [self setPixelFormat:pf];
    [self setOpenGLContext:context];
    
    NSString* file_path_name = nil;
        
    file_path_name = [[NSBundle mainBundle] pathForResource:@"model" ofType:@"ply"];
    [self load_mesh:[file_path_name cStringUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL* url = [[NSBundle mainBundle] resourceURL];
    file_path_name = [url path];
    
    file_path_name = [[NSBundle mainBundle] pathForResource:@"texture" ofType:@"jpg"];
    mesh->set_diffuse_tex_id(gl_load_texture2D([file_path_name cStringUsingEncoding:NSUTF8StringEncoding]));

    
    GetGLError();
}

- (void) prepareOpenGL
{
	[super prepareOpenGL];
	
	[self init_gl];
	
	CVDisplayLinkCreateWithActiveCGDisplays(&display_link);
    CVDisplayLinkSetOutputCallback(display_link, &display_link_callback, self);
	
	CGLContextObj cgl_context = [[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cgl_pixel_fmt = [[self pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(display_link, cgl_context, cgl_pixel_fmt);
	CVDisplayLinkStart(display_link);
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(window_will_close:)
												 name:NSWindowWillCloseNotification
											   object:[self window]];
}

- (void) window_will_close:(NSNotification*)notification
{
	CVDisplayLinkStop(display_link);
}

- (void) init_gl
{
	[[self openGLContext] makeCurrentContext];
	GLint swapInt = 1;
	[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	renderer = [[CRenderer alloc] init];
    
    mouse_x0 = mouse_y0 = 0.0;    
    
    [renderer set_ambiant_contrib:[sl_ambiant_contrib floatValue]];
    [renderer set_diffuse_contrib:[sl_diffuse_contrib floatValue]];
    [renderer set_spec_contrib:[sl_spec_contrib floatValue]];
    [renderer set_mat_shininess:[sl_mat_shininess floatValue]];
}

- (void) reshape
{	
	[super reshape];
	
	CGLLockContext([[self openGLContext] CGLContextObj]);
	NSRect view_rect = [self bounds];
    NSRect view_rect_pixel = view_rect;
	[renderer resizeWithWidth:view_rect_pixel.size.width
                      AndHeight:view_rect_pixel.size.height];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}


#pragma mark - IBActions


-(IBAction)sl_diffuse_contrib_pressed:(NSSlider*)sender
{
    [renderer set_diffuse_contrib:[sender floatValue]];
    [self setNeedsDisplay:YES];
}


-(IBAction)sl_ambiant_contrib_pressed:(NSSlider*)sender
{
    [renderer set_ambiant_contrib:[sender floatValue]];
    [self setNeedsDisplay:YES];
}


-(IBAction)sl_spec_contrib_pressed:(NSSlider*)sender
{
    [renderer set_spec_contrib:[sender floatValue]];
    [self setNeedsDisplay:YES];
}


-(IBAction)sl_mat_shininess_pressed:(NSSlider*)sender
{
    [renderer set_mat_shininess:[sender floatValue]];
    [self setNeedsDisplay:YES];
}




-(IBAction)bt_load_mesh_pressed:(NSButton*)sender
{
    NSArray* fexts = [[NSArray alloc] initWithObjects:@"ply", nil];
    NSArray* path = open_files(fexts);
    [fexts release];
    
    if ( !path )
        return;
    
    NSString* fname;

    if ( [path count] == 1 )
        fname = [[path objectAtIndex:0] path];
    
    // On préserve les textures.
    GLint diff_tex_id = mesh->get_diffuse_tex_id();
    
    if ( mesh )
        delete mesh;
    mesh = 0;
    
    [self load_mesh:[fname cStringUsingEncoding:NSUTF8StringEncoding]];

    mesh->set_diffuse_tex_id(diff_tex_id);

    [self draw_view];
}

NSString* choose_image_file()
{
    NSArray* fexts = [[NSArray alloc] initWithObjects:@"jpg", nil];
    NSArray* path = open_files(fexts);

    [fexts release];
    
    if ( !path )
        return 0;
    
    if ( [path count] != 1 )
        return 0;
    
    NSString* fname;
    fname = [[path objectAtIndex:0] path];
    
    return fname;

}

-(IBAction)bt_load_image_pressed:(NSButton*)sender
{
    NSString* fname = choose_image_file();
    if ( !fname )
        return;
    
    mesh->delete_diffuse_tex();
    mesh->set_diffuse_tex_id(gl_load_texture2D([fname cStringUsingEncoding:NSUTF8StringEncoding]));

    [self draw_view];
}


-(IBAction)bt_start_pressed:(NSButton*)sender
{
    if ( frame_timer )
        return;
    frame_timer = [NSTimer timerWithTimeInterval:(1.0/60.0) target:self
                                       selector:@selector(calc_frame:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:frame_timer forMode: NSDefaultRunLoopMode];
   
    //** TODO: Réinitialiser la simulation.
}

-(IBAction)bt_stop_pressed:(NSButton*)sender
{
    if ( frame_timer )
    {
        [frame_timer invalidate];
        frame_timer = 0;
    }
}



#pragma mark - Interaction



-(void)mouseDown:(NSEvent *)evt
{
    break_debug();
    
    //printf("md: %f : %f\n",  rotx, roty);
    NSPoint loc = [self convertPoint:[evt locationInWindow] fromView:nil];
    mouse_x0 = loc.x;
    mouse_y0 = loc.y;
}


static const float pan_factor = 0.05;
static const float rot_factor = 0.25;
-(void)mouseDragged:(NSEvent*)evt
{
    NSPoint loc = [self convertPoint:[evt locationInWindow] fromView:nil];
    float dx = mouse_x0 - loc.x;
    float dy = mouse_y0 - loc.y;
    
    if ( [evt modifierFlags] & NSAlternateKeyMask )
       [renderer incr_camposz:pan_factor*dy];
    else
        [renderer incr_rot:rot_factor*dy :rot_factor*dx :0.0];
    
    mouse_x0 = loc.x;
    mouse_y0 = loc.y;

    [self setNeedsDisplay:YES];
}

#pragma mark - 



- (void)calc_frame:(NSTimer *)pTimer
{
    //static long test_counter = 0;
    //cout << "calc_frame : " << test_counter++ << endl;
    
    //** FAIRE LE DESSIN ICI.
    
    [self setNeedsDisplay:YES];
}


-(void)drawRect: (NSRect) rect
{
	[self draw_view];
}

- (void) draw_view
{	 
	[[self openGLContext] makeCurrentContext];
	CGLLockContext([[self openGLContext] CGLContextObj]);
    [renderer render:mesh];
    
    
	CGLFlushDrawable([[self openGLContext] CGLContextObj]);
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

- (void) dealloc
{
	// Release the display link AFTER display link has been released
	CVDisplayLinkStop(display_link);
	CVDisplayLinkRelease(display_link);

	[renderer release];
	
	[super dealloc];
}
@end
