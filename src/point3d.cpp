
#include "point3d.h"

#include <cmath>

using namespace std;

const float CPoint3D::epsilon(0.00001F);

// Main droite
CVect3D ProdVect(const CVect3D& P, const CVect3D& Q) 
{ 
	return CPoint3D(P[1]*Q[2]-P[2]*Q[1], P[2]*Q[0]-P[0]*Q[2], P[0]*Q[1]-P[1]*Q[0]);
}

// --------------------------------------------------------------------------------
//  class:	CPoint3D
// --------------------------------------------------------------------------------


CPoint3D& CPoint3D::operator=(const CPoint3D& P) 
{ 
	if ( &P != this )
	{
		X[0] = P.X[0]; 
		X[1] = P.X[1]; 
		X[2] = P.X[2]; 
	}
	return *this; 
}

	
CPoint3D operator+(const CPoint3D& P, const CVect3D& V) 
{
	CPoint3D R(0,0,0);
	R.X[0] = P.X[0] + V.X[0]; 
	R.X[1] = P.X[1] + V.X[1]; 
	R.X[2] = P.X[2] + V.X[2]; 
	return R;
}

	
CPoint3D operator-(const CPoint3D& P, const CVect3D& V) 
{
	CPoint3D R(0,0,0);
	R.X[0] = P.X[0] - V.X[0]; 
	R.X[1] = P.X[1] - V.X[1]; 
	R.X[2] = P.X[2] - V.X[2]; 
	return R;
} 

		
CPoint3D operator-(const CVect3D& V)
{
	CPoint3D R(0,0,0);
	R.X[0] = -V.X[0]; 
	R.X[1] = -V.X[1]; 
	R.X[2] = -V.X[2]; 
	return R;
}

		
CPoint3D& CPoint3D::operator+=(const CVect3D& V)
{
	X[0] += V.X[0]; 
	X[1] += V.X[1]; 
	X[2] += V.X[2]; 
	return *this;
}

		
CPoint3D& CPoint3D::operator-=(const CVect3D& V)
{
	X[0] -= V.X[0]; 
	X[1] -= V.X[1]; 
	X[2] -= V.X[2]; 
	return *this;
}


CPoint3D& CPoint3D::operator*=(const float& a)
{
	X[0] *= a; 
	X[1] *= a; 
	X[2] *= a; 
	return *this;	
}


bool operator==( const CPoint3D& P,  const CPoint3D& Q)
{
	if (std::fabs(P.X[0] - Q.X[0]) > CPoint3D::epsilon) return false; 
	if (std::fabs(P.X[1] - Q.X[1]) > CPoint3D::epsilon) return false; 
	if (std::fabs(P.X[2] - Q.X[2]) > CPoint3D::epsilon) return false; 
	return true;
}


bool operator!=( const CPoint3D& P,  const CPoint3D& Q) 
{
	return !(P==Q);
}


bool	CPoint3D::IsNull() const
{
	if ( std::fabs(X[0]) >= CPoint3D::epsilon )  return false; 
	if ( std::fabs(X[1]) >= CPoint3D::epsilon )  return false; 
	if ( std::fabs(X[2]) >= CPoint3D::epsilon )  return false; 
	return true;

}


CPoint3D  CPoint3D::Projection(const CPoint3D& A, const CPoint3D& B) const
{
	CVect3D U = B - A;
	CVect3D V = (*this) - A;

	return A + (ProdScal(U,V)/ProdScal(U,U))*U;
}
	
// Calcul du produit scalaire normalisé de U sur *this.
float CPoint3D::ProdScalNorm(const CVect3D& U) const
{
	return ProdScal(U, *this)/ProdScal(*this, *this);
}


CVect3D	CPoint3D::ProjSur(const CVect3D& V) const
{
	return (ProdScal(*this,V)/ProdScal(V,V))*V;
}

// On suppose que N est unitaire.
CPoint3D CPoint3D::ProjPlan(const CPoint3D& P, const CVect3D& N)
{
	return *this + ProdScal(N, P - *this) * N;
}


// --------------------------------------------------------------------------------
// Fonction : Coords
//
// Détermine les coordonnées barycentriques 3D d'un point
// --------------------------------------------------------------------------------
void CPoint3D::CoordsBary(const CPoint3D& p0, const CPoint3D& p1, const CPoint3D& p2, double& a0, double& a1, double& a2) const
{
	CVect3D v01, v02, pp, N;
	float len;

	v01 = p1 - p0;
	v02 = p2 - p0;
	pp = (*this - p0);
	N = ::ProdVect(v01, v02);
	len = 1/(::Module(N));

	a0 = ::Module(::ProdVect((p2 - p1), (*this - p1)))*len;
	a1 = ::Module(::ProdVect(v02, pp))*len;
	a2 = ::Module(::ProdVect(v01, pp))*len;
}

CVect3D Normalise(const CVect3D& V) 
{
	if ( V.IsNull() ) 
		throw "ExcCPoint3D::NulVect";
	return 1/Module(V)*V;
}

float ProdScal(const CVect3D& P, const CVect3D& Q) 
{
	float s = 0;
	s += P[0]*Q[0];
	s += P[1]*Q[1];
	s += P[2]*Q[2];
	return s;
}


float Dist(const CPoint3D& A, const CPoint3D& B) 
{
	return std::sqrt(Dist_2(A, B));
}

// La distance entre deux CPoint3D* est définie par la distance entre les
// points auxquels on réfère.

float Dist(const CPoint3D* A, const CPoint3D* B) 
{
	return ::Dist(*A, *B);
}

float Dist_2(const CPoint3D& A, const CPoint3D& B) 
{
	float s = 0;
	s += (A[0]-B[0])*(A[0]-B[0]);
	s += (A[1]-B[1])*(A[1]-B[1]);
	s += (A[2]-B[2])*(A[2]-B[2]);
	return s;
}

float Module(const CVect3D& V)
{
	float s = 0;
	s += V[0]*V[0];
	s += V[1]*V[1];
	s += V[2]*V[2];
	return std::sqrt(s);
}

CVect3D operator*(const float& a, const CVect3D& Q) 
{ 
	CVect3D R;
	R.X[0]= a*Q.X[0];
	R.X[1]= a*Q.X[1];
	R.X[2]= a*Q.X[2];
	return R;
}

CVect3D operator/(const CVect3D& Q, const float& a) 
{ 
	CVect3D R;
	R.X[0]= Q.X[0]/a;
	R.X[1]= Q.X[1]/a;
	R.X[2]= Q.X[2]/a;
	return R;
}

float Angle(const CVect3D& U, const CVect3D& V)
{
	float u;
	float modU;
	float modV;
	
	modU = Module(U);
	modV = Module(V);
	
	if ( modU < CPoint3D::epsilon || modU < CPoint3D::epsilon ) 
		throw "ExcCPoint3D::NulVect";
	u = ProdScal(U,V)/(modU*modV);
	if ( u >  1 ) u =  1;
	if ( u < -1 ) u = -1;
	return std::acos(u);

}

