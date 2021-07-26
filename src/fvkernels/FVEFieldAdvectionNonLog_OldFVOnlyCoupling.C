
#include "FVEFieldAdvectionNonLog_OldFVOnlyCoupling.h"

registerADMooseObject("rotomApp", FVEFieldAdvectionNonLog_OldFVOnlyCoupling);

InputParameters
FVEFieldAdvectionNonLog_OldFVOnlyCoupling::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription("Generic electric field driven advection term using finite volume method.");
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity.");
  return params;
}

FVEFieldAdvectionNonLog_OldFVOnlyCoupling::FVEFieldAdvectionNonLog_OldFVOnlyCoupling(const InputParameters & params)
  : FVFluxKernel(params),
    _mu_elem(getADMaterialProperty<Real>("mu" + _var.name())),
    _mu_neighbor(getNeighborADMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name())),
    _potential_var(dynamic_cast<const MooseVariableFV<Real> *>(getFieldVar("potential", 0))),
    _potential_elem(adCoupledValue("potential")),
    _potential_neighbor(adCoupledNeighborValue("potential"))
{
}

ADReal
FVEFieldAdvectionNonLog_OldFVOnlyCoupling::computeQpResidual()
{
  ADReal u_interface;

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

  interpolate(InterpMethod::Average,
              u_interface,
              _u_elem[_qp],
              _u_neighbor[_qp],
              *_face_info,
              true);

  return _sign[_qp] * mobility * -1.0 * dpotential_dn * u_interface;
}
