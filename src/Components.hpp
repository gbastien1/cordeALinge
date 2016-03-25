//
//  Components.hpp
//  8trd147-d2
//
//  Created by Etudiant on 2016-03-25.
//
//

#ifndef Components_hpp
#define Components_hpp

#include <stdio.h>
#include <math.h>
#include "mesh.h"

#endif /* Components_hpp */


/* GB
 * rectangle shape formed with two triangles
 */
class Rectangle : public CMesh {
public:
    Rectangle(int width, int height) {
        
        //first, init vertices with number of vertices. This allows the use
        //of bracket operator to push vertex in the vector
        for (int i = 0; i < 4; i++) {
            vertices.push_back(NULL);
        }
        
        //create vertices and add them to vertices vector, with u,v coords
        vertices[0] = new CVertex(0, CPoint3D(0, 0, 0),          0.0, 0.0);
        vertices[1] = new CVertex(1, CPoint3D(0, height, 0),     0.0, 1.0);
        vertices[2] = new CVertex(2, CPoint3D(width, height, 0), 1.0, 1.0);
        vertices[3] = new CVertex(3, CPoint3D(width, 0, 0),      1.0, 0.0);
        
        //create corresponding triangles
        CTriangle* tri1(new CTriangle(vertices[0], vertices[1], vertices[2]));
        CTriangle* tri2(new CTriangle(vertices[0], vertices[2], vertices[3]));
        triangles.push_back(tri1);
        triangles.push_back(tri2);
        
        //adjacent triangles
        vertices[0]->triangles.push_back(tri1);
        vertices[0]->triangles.push_back(tri2);
        vertices[1]->triangles.push_back(tri1);
        vertices[2]->triangles.push_back(tri1);
        vertices[2]->triangles.push_back(tri2);
        vertices[3]->triangles.push_back(tri2);
    }
};

/**
 * GB
 * class to draw a line between two points
 * TODO enough to write only 2 vertices?
 */
class Line : public CMesh {
public:
    Line(CPoint3D p1, CPoint3D p2) {
        vertices.push_back(new CVertex(0, p1, 0.0, 0.0));
        vertices.push_back(new CVertex(1, p2, 0.0, 0.0));
    }
};

/**
 * GB
 * class for post objects
 * TODO: check u,v coords, probably dont work because
 * supposed to be in range 0..1, but in range -1..1
 */
#define PI 3.14159265
class Cylinder : public CMesh {
public:
    Cylinder(int height, int radius, int slices) {
        float theta = (2 * PI ) / slices;
        int u, v;
        
        //define vertices for top circle
        vertices.push_back(new CVertex(0, CPoint3D(0, height, 0), 0.5, 0.5)); //center of top circle
        for (int i = 0; i < slices; i++) {
            u = cos(theta*i);
            v = sin(theta*i);
            vertices.push_back(new CVertex(i+1, CPoint3D(radius*cos(theta*i), height, radius*sin(theta*i)), u, v));
        }
        
        //define vertices for bottom circle
        vertices.push_back(new CVertex(slices + 1, CPoint3D(0, 0, 0), 0.5, 0.5)); //center of bottom circle
        for (int i = slices; i < slices*2; i++) {
            u = cos(theta*i);
            v = sin(theta*i);
            vertices.push_back(new CVertex(i+2, CPoint3D(radius*cos(theta*i), 0, radius*sin(theta*i)), u, v));
        }
        
        //define triangles for top circle
        for (int i = 1; i <= slices; i++) {
            CTriangle* tri(new CTriangle(vertices[0], vertices[i], vertices[i+1]));
            triangles.push_back(tri);
            
            //adjacent triangles
            vertices[0]->triangles.push_back(tri);
            vertices[i]->triangles.push_back(tri);
            vertices[i+1]->triangles.push_back(tri);
        }
        
        //define triangles for bottom circle
        for (int i = slices; i < slices*2; i++) {
            CTriangle* tri(new CTriangle(vertices[slices], vertices[i+1], vertices[i+2]));
            triangles.push_back(tri);
            
            //adjacent triangles
            vertices[slices]->triangles.push_back(tri);
            vertices[i+1]->triangles.push_back(tri);
            vertices[i+2]->triangles.push_back(tri);
        }
        
        //define triangles for sides
        for (int i = 0; i < slices; i++) { //2 triangles per side
            
                CTriangle* tri1(new CTriangle(vertices[i+1], vertices[i+2], vertices[i + slices + 1]));
                triangles.push_back(tri1);
                
                //adjacent triangles
                vertices[i+1]->triangles.push_back(tri1);
                vertices[i+2]->triangles.push_back(tri1);
                vertices[i+slices+1]->triangles.push_back(tri1);
            
                CTriangle* tri2(new CTriangle(vertices[i+2], vertices[i + slices + 2], vertices[i + slices + 1]));
                triangles.push_back(tri2);
                
                //adjacent triangles
                vertices[i+2]->triangles.push_back(tri2);
                vertices[i+slices+2]->triangles.push_back(tri2);
                vertices[i+slices+1]->triangles.push_back(tri2);
        }
    }
};


/**
 * ABD
 * class to draw the sheet that will de distorted with "wind"
 */
class Drap : public CMesh {
public:
    Drap() {
        for (int i = 0; i < 1200; i++) {
            vertices.push_back(NULL);
        }
        
        int compteurVertice = 0;
        for(int i = 0; i < 30; i++)
        {
            for(int j = 0; j < 40; j++)
            {
                vertices[compteurVertice] = new CVertex(compteurVertice, CPoint3D(-2 + ((float)(j/10)), 6 - ((float)(i/10)), 0), 0.0, 0.0);
                compteurVertice++;
            }
        }
        
        for(int i = 0; i < 29; i++)
        {
            for(int j = 0; j < 39; j++)
            {
                if(i % 2 == 0)
                {
                    if(j % 2 == 0)
                    {
                        CTriangle* tri1(new CTriangle(vertices[(i * 40) + j], vertices[(i * 40) + (j + 1)], vertices[((i + 1) * 40) + (j + 1)]));
                        CTriangle* tri2(new CTriangle(vertices[(i * 40) + j], vertices[((i + 1) * 40) + (j + 1)], vertices[((i + 1) * 40) + j]));
                        triangles.push_back(tri1);
                        triangles.push_back(tri2);
                    }
                    else
                    {
                        CTriangle* tri1(new CTriangle(vertices[(i * 40) + j], vertices[(i * 40) + (j + 1)], vertices[((i + 1) * 40) + j]));
                        CTriangle* tri2(new CTriangle(vertices[(i * 40) + (j + 1)], vertices[((i + 1) * 40) + (j + 1)], vertices[((i + 1) * 40) + j]));
                        triangles.push_back(tri1);
                        triangles.push_back(tri2);
                    }
                }
                else
                {
                    if(j % 2 == 0)
                    {
                        CTriangle* tri1(new CTriangle(vertices[(i * 40) + j], vertices[(i * 40) + (j + 1)], vertices[((i + 1) * 40) + j]));
                        CTriangle* tri2(new CTriangle(vertices[(i * 40) + (j + 1)], vertices[((i + 1) * 40) + (j + 1)], vertices[((i + 1) * 40) + j]));
                        triangles.push_back(tri1);
                        triangles.push_back(tri2);
                    }
                    else
                    {
                        CTriangle* tri1(new CTriangle(vertices[(i * 40) + j], vertices[(i * 40) + (j + 1)], vertices[((i + 1) * 40) + (j + 1)]));
                        CTriangle* tri2(new CTriangle(vertices[(i * 40) + j], vertices[((i + 1) * 40) + (j + 1)], vertices[((i + 1) * 40) + j]));
                        triangles.push_back(tri1);
                        triangles.push_back(tri2);
                    }
                }
            }
        }
    }
};
