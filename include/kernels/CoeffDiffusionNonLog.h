
#pragma once

#include "ADKernel.h"

/*
 * This diffusion kernel should only be used with species whose values are in
 * the logarithmic form.
 */

class CoeffDiffusionNonLog : public ADKernel
{
public:
  static InputParameters validParams();

  CoeffDiffusionNonLog(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:
  /// Position units
  const Real _r_units;

  /// The diffusion coefficient (either constant or mixture-averaged)
  const ADMaterialProperty<Real> & _diffusivity;
};
