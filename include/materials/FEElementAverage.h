
#pragma once

#include "Material.h"

class FEElementAverage : public Material
{
public:
  static InputParameters validParams();

  FEElementAverage(const InputParameters & parameters);

protected:
  virtual void computeProperties() override;
  virtual void computeQpProperties() override;

  ADMaterialProperty<Real> & _var_average;
  const ADVariableValue & _var_value;
  MooseVariable & _var;

  const Real & _current_elem_volume;
  const Real & _current_side_volume;
  const MooseArray<ADReal> & _ad_JxW;
  const MooseArray<ADReal> & _ad_coord;
};
