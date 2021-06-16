
#pragma once

#include "FVFluxKernel.h"

/// FVCoeffDiffusionNonLog implements a standard diffusion term:
///
///     - strong form: \nabla \cdot k \nabla u
///
///     - weak form: \int_{A} k \nabla u \cdot \vec{n} dA
///
/// It uses/requests a material property named "coeff" for k. An average of
/// the elem and neighbor k-values (which should be face-values) is used to
/// compute k on the face. Cross-diffusion correction factors are currently not
/// implemented for the "grad_u*n" term.
class FVCoeffDiffusionNonLog : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVCoeffDiffusionNonLog(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  const ADMaterialProperty<Real> & _diff_elem;
  const ADMaterialProperty<Real> & _diff_neighbor;
};
