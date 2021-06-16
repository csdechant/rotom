
#pragma once

#include "FVFluxKernel.h"

class FVEFieldAdvectionNonLog : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVEFieldAdvectionNonLog(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  const ADMaterialProperty<Real> & _mu_elem;
  const ADMaterialProperty<Real> & _mu_neighbor;

  const MaterialProperty<Real> & _sign;

  const ADMaterialProperty<Real> & _potential_elem;
  const ADMaterialProperty<Real> & _potential_neighbor;
};
