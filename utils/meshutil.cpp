#include "mesh.mm"
using namespace std;

class Rectangle : public CMesh {

	int width, height;

	/**
	 * Create vertices and indices for drawing 
	 * a rectangle in local coordinates
	 */
	Rectangle(int width, int height) {
		// TODO populate vertices vector with CVertex*
		// create 2 CTriangle with vertices
		for (int i = 0; i < 4; i++) {
			vertices.push_back(null);
		}
		vertices[0] = new CVertex(0, CPoint3D(0, 0, 0), 0.0, 0.0);
		vertices[1] = new CVertex(1, CPoint3D(0, height, 0), 0.0, 0.0);
		vertices[2] = new CVertex(2, CPoint3D(width, height, 0), 0.0, 0.0);
		vertices[3] = new CVertex(3, CPoint3D(wicth, 0, 0), 0.0, 0.0);

		CTriangle* tri1(new CTriangle(vertices[0], vertices[1], vertices[2]));
        Ctriangle* tri2(new CTriangle(vertices[0], vertices[2], vertices[3]));
        triangles.push_back(tri1);
        triangles.push_back(tri2);
	}
}