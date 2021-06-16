
#include "CoeffDiffusionNonLog.h"

registerADMooseObject("rotomApp", CoeffDiffusionNonLog);

InputParameters
CoeffDiffusionNonLog::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Generic diffusion term, where the "
                             "Jacobian is computed using forward automatic differentiation.");
  return params;
}

CoeffDiffusionNonLog::CoeffDiffusionNonLog(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _diffusivity(getADMaterialProperty<Real>("diff" + _var.name()))
{
}

ADReal
CoeffDiffusionNonLog::computeQpResidual()
{
  return -_diffusivity[_qp] * _grad_u[_qp] * _r_units * -_grad_test[_i][_qp] *
         _r_units;
}
