
#pragma once

#include "ADKernel.h"

class ChargeSourceMoles_KVNonLog : public ADKernel
{
public:
  static InputParameters validParams();

  ChargeSourceMoles_KVNonLog(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// Coupled variable
  MooseVariable & _charged_var;
  const ADVariableValue & _charged;

  /// Material properties (regular because these are constants)
  const MaterialProperty<Real> & _e;
  const MaterialProperty<Real> & _sgn;
  const MaterialProperty<Real> & _N_A;

  /// Units scaling
  const std::string & _potential_units;
  Real _voltage_scaling;
};
