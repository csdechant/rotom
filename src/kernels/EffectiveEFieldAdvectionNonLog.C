
#include "EffectiveEFieldAdvectionNonLog.h"

registerADMooseObject("rotomApp", EffectiveEFieldAdvectionNonLog);

InputParameters
EffectiveEFieldAdvectionNonLog::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredCoupledVar("u", "x-Effective Efield");
  params.addCoupledVar("v", 0, "y-Effective Efield"); // only required in 2D and 3D
  params.addCoupledVar("w", 0, "z-Effective Efield"); // only required in 3D
  params.addRequiredParam<Real>("position_units", "Units of position.");
  return params;
}

EffectiveEFieldAdvectionNonLog::EffectiveEFieldAdvectionNonLog(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _mu(getADMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name())),
    _u_Efield(adCoupledValue("u")),
    _v_Efield(adCoupledValue("v")),
    _w_Efield(adCoupledValue("w"))
{
}

ADReal
EffectiveEFieldAdvectionNonLog::computeQpResidual()
{
  ADRealVectorValue Efield(_u_Efield[_qp], _v_Efield[_qp], _w_Efield[_qp]);

  return _mu[_qp] * _sign[_qp] * _u[_qp] * Efield * _r_units *
         -_grad_test[_i][_qp] * _r_units;
}
