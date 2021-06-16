//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVCoeffDiffusionNonLog.h"

registerMooseObject("rotomApp", FVCoeffDiffusionNonLog);

InputParameters
FVCoeffDiffusionNonLog::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription("Generic diffusion term for finite volume method.");
  params.set<unsigned short>("ghost_layers") = 2;
  return params;
}

FVCoeffDiffusionNonLog::FVCoeffDiffusionNonLog(const InputParameters & params)
  : FVFluxKernel(params),
    _diff_elem(getADMaterialProperty<Real>("diff" + _var.name())),
    _diff_neighbor(getNeighborADMaterialProperty<Real>("diff" + _var.name()))
{
}

ADReal
FVCoeffDiffusionNonLog::computeQpResidual()
{
  auto dudn = gradUDotNormal();

  // Eventually, it will be nice to offer automatic-switching triggered by
  // input parameters to change between different interpolation methods for
  // this.
  ADReal diffusivity;
  interpolate(Moose::FV::InterpMethod::Average,
              diffusivity,
              _diff_elem[_qp],
              _diff_neighbor[_qp],
              *_face_info,
              true);

  return -1.0 * diffusivity * dudn;
}
