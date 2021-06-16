//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVfromMatBC.h"

registerADMooseObject("MooseApp", FVfromMatBC);

InputParameters
FVfromMatBC::validParams()
{
  InputParameters params = FVFluxBC::validParams();
  params.addClassDescription("Convert Material property to FV variable at a boundary.");
  params.addRequiredParam<MaterialPropertyName>("potential", "The element average potential as a material property.");
  return params;
}

FVfromMatBC::FVfromMatBC(const InputParameters & params)
  : FVFluxBC(params),
    _potential_elem(getADMaterialProperty<Real>("potential")),
    _potential_neighbor(getNeighborADMaterialProperty<Real>("potential"))
{
}

ADReal
FVfromMatBC::computeQpResidual()
{
  ADReal u_interface;
  ADReal potential;

  using namespace Moose::FV;

  // Currently only Average is supported for the velocity
  interpolate(InterpMethod::Average,
              potential,
              _potential_elem[_qp],
              _potential_neighbor[_qp],
              *_face_info,
              true);

  interpolate(InterpMethod::Average,
              u_interface,
              _u[_qp],
              _u_neighbor[_qp],
              *_face_info,
              true);

  //return (u_interface - potential);
  return potential / (_face_info->faceArea() * _face_info->faceCoord());
}
