
#pragma once

#include "FVFluxKernel.h"

class FVCoupledDensityEFieldAdvectionNonLog : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVCoupledDensityEFieldAdvectionNonLog(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  const ADMaterialProperty<Real> & _mu_elem;
  const ADMaterialProperty<Real> & _mu_neighbor;

  const MaterialProperty<Real> & _sign;

  const MooseVariableFV<Real> * _potential_var;
  const ADVariableValue & _potential_elem;
  const ADVariableValue & _potential_neighbor;

  const ADVariableValue & _density_elem;
};
