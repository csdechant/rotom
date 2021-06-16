
#pragma once

#include "ADKernel.h"

class EFieldAdvectionNonLog : public ADKernel
{
public:
  static InputParameters validParams();

  EFieldAdvectionNonLog(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:
  /// Position units
  const Real _r_units;

  /// The diffusion coefficient (either constant or mixture-averaged)
  const ADMaterialProperty<Real> & _mu;
  const MaterialProperty<Real> & _sign;

  const ADVariableGradient & _grad_potential;
};
