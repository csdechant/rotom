
#include "ChargeSourceMoles_KVNonLog.h"

registerMooseObject("rotomApp", ChargeSourceMoles_KVNonLog);

InputParameters
ChargeSourceMoles_KVNonLog::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredCoupledVar("charged", "The charged species");
  params.addRequiredParam<std::string>("potential_units", "The potential units.");
  params.addClassDescription(
      "Used for adding charged sources to Poisson’s equation. This kernel"
      "assumes that densities are measured in units of mol/volume as opposed to #/volume");
  return params;
}

ChargeSourceMoles_KVNonLog::ChargeSourceMoles_KVNonLog(const InputParameters & parameters)
  : ADKernel(parameters),
    _charged_var(*getVar("charged", 0)),
    _charged(adCoupledValue("charged")),
    _e(getMaterialProperty<Real>("e")),
    _sgn(getMaterialProperty<Real>("sgn" + _charged_var.name())),
    _N_A(getMaterialProperty<Real>("N_A")),
    _potential_units(getParam<std::string>("potential_units"))
{
  if (_potential_units.compare("V") == 0)
    _voltage_scaling = 1.;
  else if (_potential_units.compare("kV") == 0)
    _voltage_scaling = 1000;
}

ADReal
ChargeSourceMoles_KVNonLog::computeQpResidual()
{
  return -_test[_i][_qp] * _e[_qp] * _sgn[_qp] * _N_A[_qp] * _charged[_qp] /
         _voltage_scaling;
}
