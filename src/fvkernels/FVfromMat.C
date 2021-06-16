//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVfromMat.h"

registerADMooseObject("MooseApp", FVfromMat);

InputParameters
FVfromMat::validParams()
{
  InputParameters params = FVElementalKernel::validParams();
  params.addClassDescription("Convert Material property to FV variable.");
  params.addRequiredParam<MaterialPropertyName>("potential", "The element average potential as a material property.");
  return params;
}

FVfromMat::FVfromMat(const InputParameters & parameters)
  : FVElementalKernel(parameters),
    _potential_elem(getADMaterialProperty<Real>("potential"))
{
}

ADReal
FVfromMat::computeQpResidual()
{
  return _u[_qp] - _potential_elem[_qp];
}
