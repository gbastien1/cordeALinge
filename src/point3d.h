#pragma once
#include <OpenGL/gl3.h>

class CPoint3D;
typedef CPoint3D CVect3D;

// --------------------------------------------------------------------------------
//  Classe:	CPoint3D
// 
//  Par:   Yves Chiricota
//  Date:  12/09/99
//  MAJ:    
// --------------------------------------------------------------------------------
class CPoint3D  {
public:
	CPoint3D(const float& x0 = 0.0, const float& x1 = 0.0, const float& x2 = 0.0)
		{ X[0] = x0; X[1] = x1; X[2] = x2; }

	// Opérations
	const float&	operator[](int i) const { return X[i]; } 	// Cette fonction ne fait aucune validation.
	CPoint3D&		operator=(const CPoint3D& P);
	friend bool		operator==( const CPoint3D& P,  const CPoint3D& Q);
	friend bool		operator!=( const CPoint3D& P,  const CPoint3D& Q);
	friend CPoint3D	operator+(const CPoint3D& P, const CVect3D& V);
	friend CVect3D	operator-(const CPoint3D& P, const CPoint3D& V) ;
	friend CPoint3D	operator-(const CVect3D& V);
	CPoint3D&		operator+=(const CVect3D& V);
	CPoint3D&		operator-=(const CVect3D& V);
	CPoint3D&		operator*=(const float& a);
	friend CVect3D	operator*(const float& a, const CVect3D& V);		
	friend CVect3D	operator/(const CVect3D& V, const float& a);	
	

	virtual ~CPoint3D() {}
	bool	IsNull() const;


	friend float	ProdScal(const CVect3D& V, const CVect3D& U);
	friend float	Dist(const CPoint3D& P, const CPoint3D& Q);
	friend float	Dist_2(const CPoint3D& P, const CPoint3D& Q);
	friend float	Module(const CVect3D& V);
	friend CVect3D	Normalise(const CVect3D& P);
	friend float	Angle(const CVect3D& V, const CVect3D& U);
	CPoint3D	Projection(const CPoint3D& A, const CPoint3D& B) const;	
	float		ProdScalNorm(const CVect3D& U) const;
	CVect3D		ProjSur(const CVect3D&) const;
	CPoint3D	ProjPlan(const CPoint3D& P, const CVect3D& N);
	void		CoordsBary(const CPoint3D& p0, const CPoint3D& p1, const CPoint3D& p2, double& a0, double& a1, double& a2) const;

	friend  CVect3D	ProdVect(const CVect3D& V, const CVect3D& U);


public:
	static const float	epsilon;

private:
	float X[3];

};

float Module(const CVect3D& V);
float Angle(const CVect3D& U, const CVect3D& V);
float Dist(const CPoint3D& A, const CPoint3D& B);
