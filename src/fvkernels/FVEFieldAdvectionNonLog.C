
#include "FVEFieldAdvectionNonLog.h"

registerADMooseObject("rotomApp", FVEFieldAdvectionNonLog);

InputParameters
FVEFieldAdvectionNonLog::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription("Generic electric field driven advection term using finite volume method.");
  params.addRequiredParam<MaterialPropertyName>("potential", "The element average potential as a material property.");
  return params;
}

FVEFieldAdvectionNonLog::FVEFieldAdvectionNonLog(const InputParameters & params)
  : FVFluxKernel(params),
    _mu_elem(getADMaterialProperty<Real>("mu" + _var.name())),
    _mu_neighbor(getNeighborADMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name())),
    _potential_elem(getADMaterialProperty<Real>("potential")),
    _potential_neighbor(getNeighborADMaterialProperty<Real>("potential"))
{
}

ADReal
FVEFieldAdvectionNonLog::computeQpResidual()
{
  ADReal u_interface;

  using namespace Moose::FV;

  ADReal mobility;
  interpolate(InterpMethod::Average,
              mobility,
              _mu_elem[_qp],
              _mu_neighbor[_qp],
              *_face_info,
              true);

  ADReal _grad_pot_normal = (_potential_neighbor[_qp] - _potential_elem[_qp]) / _face_info->dCFMag();

  //interpolate(InterpMethod::Average,
  //            _Efield,
  //            _Efield_elem[_qp],
  //            _Efield_neighbor[_qp],
  //            *_face_info,
  //            true);

  interpolate(InterpMethod::Average,
              u_interface,
              _u_elem[_qp],
              _u_neighbor[_qp],
              *_face_info,
              true);

  return _sign[_qp] * mobility * -1.0 * _grad_pot_normal * u_interface;
}
