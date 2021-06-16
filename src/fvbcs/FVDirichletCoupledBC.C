//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVDirichletCoupledBC.h"

registerMooseObject("MooseApp", FVDirichletCoupledBC);

InputParameters
FVDirichletCoupledBC::validParams()
{
  InputParameters params = FVDirichletBCBase::validParams();
  params += TwoMaterialPropertyInterface::validParams();
  params.addClassDescription("Defines a Dirichlet boundary condition for finite volume method.");
  params.addRequiredParam<MaterialPropertyName>("potential", "The element average potential as a material property.");

  params.set<Moose::MaterialDataType>("_material_data_type") = Moose::BOUNDARY_MATERIAL_DATA;

  return params;
}

FVDirichletCoupledBC::FVDirichletCoupledBC(const InputParameters & parameters)
  : FVDirichletBCBase(parameters),
    TwoMaterialPropertyInterface(this, Moose::EMPTY_BLOCK_IDS, boundaryIDs()),
    _potential_face(getADMaterialProperty<Real>("potential"))
{
}

Real
FVDirichletCoupledBC::boundaryValue(const FaceInfo & /*fi*/) const
{
  //Real val = _potential_face[0];

  return 0;
}
