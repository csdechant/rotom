
#include "EFieldAdvectionNonLog.h"

registerADMooseObject("rotomApp", EFieldAdvectionNonLog);

InputParameters
EFieldAdvectionNonLog::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription(
      "Generic electric field driven advection term.");
  return params;
}

EFieldAdvectionNonLog::EFieldAdvectionNonLog(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _mu(getADMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name())),
    _grad_potential(adCoupledGradient("potential"))
{
}

ADReal
EFieldAdvectionNonLog::computeQpResidual()
{
  return _mu[_qp] * _sign[_qp] * _u[_qp] * -_grad_potential[_qp] * _r_units *
         -_grad_test[_i][_qp] * _r_units;
}
