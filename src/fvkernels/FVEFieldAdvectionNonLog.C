
#include "FVEFieldAdvectionNonLog.h"
#include "Assembly.h"

#include "MooseTypes.h"
#include "SubProblem.h"
#include "FEProblem.h"

#include "libmesh/numeric_vector.h"
#include "libmesh/dof_map.h"
#include "libmesh/quadrature.h"
#include "libmesh/boundary_info.h"

registerADMooseObject("rotomApp", FVEFieldAdvectionNonLog);

InputParameters
FVEFieldAdvectionNonLog::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription("Generic electric field driven advection term using finite volume method.");
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity.");
  return params;
}

FVEFieldAdvectionNonLog::FVEFieldAdvectionNonLog(const InputParameters & params)
  : FVFluxKernel(params),
    _mu_elem(getADMaterialProperty<Real>("mu" + _var.name())),
    _mu_neighbor(getNeighborADMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name()))
{
}

ADReal
FVEFieldAdvectionNonLog::computeQpResidual()
{
  ADReal u_interface;

  ADRealVectorValue grad_potential = adCoupledGradientFace("potential");

  using namespace Moose::FV;

  ADReal mobility;
  interpolate(InterpMethod::Average,
              mobility,
              _mu_elem[_qp],
              _mu_neighbor[_qp],
              *_face_info,
              true);

  interpolate(InterpMethod::Average,
              u_interface,
              _u_elem[_qp],
              _u_neighbor[_qp],
              *_face_info,
              true);

   return _sign[_qp] * mobility * -1.0 * grad_potential * _normal * u_interface;
}
