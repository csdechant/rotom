
#include "FVCoupledDensityEFieldAdvectionNonLog.h"

registerADMooseObject("rotomApp", FVCoupledDensityEFieldAdvectionNonLog);

InputParameters
FVCoupledDensityEFieldAdvectionNonLog::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription("Generic electric field driven advection term using finite volume method.");
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity (must be FV).");
  params.addRequiredCoupledVar(
      "density", "The coupled density.");
  return params;
}

FVCoupledDensityEFieldAdvectionNonLog::FVCoupledDensityEFieldAdvectionNonLog(const InputParameters & params)
  : FVFluxKernel(params),
    _mu_elem(getADMaterialProperty<Real>("mu" + _var.name())),
    _mu_neighbor(getNeighborADMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name())),
    _potential_var(dynamic_cast<const MooseVariableFV<Real> *>(getFieldVar("potential", 0))),
    _potential_elem(adCoupledValue("potential")),
    _potential_neighbor(adCoupledNeighborValue("potential")),
    _density_elem(adCoupledValue("density"))
{
}

ADReal
FVCoupledDensityEFieldAdvectionNonLog::computeQpResidual()
{
  auto dpotential_dn = Moose::FV::gradUDotNormal(_potential_elem[_qp],
                                                 _potential_neighbor[_qp],
                                                 *_face_info,
                                                 *_potential_var);

  using namespace Moose::FV;

  ADReal mobility;
  interpolate(InterpMethod::Average,
              mobility,
              _mu_elem[_qp],
              _mu_neighbor[_qp],
              *_face_info,
              true);

  return _sign[_qp] * mobility * -1.0 * dpotential_dn * _density_elem[_qp];
}
