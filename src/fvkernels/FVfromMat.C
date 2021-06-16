
#include "FVfromMat.h"

registerADMooseObject("rotomApp", FVfromMat);

InputParameters
FVfromMat::validParams()
{
  InputParameters params = FVElementalKernel::validParams();
  params.addClassDescription("Convert Material property to FV variable.");
  params.addRequiredParam<MaterialPropertyName>("FE_property", "The FE element average value as a material property.");
  return params;
}

FVfromMat::FVfromMat(const InputParameters & parameters)
  : FVElementalKernel(parameters),
    _FE_elem(getADMaterialProperty<Real>("FE_property"))
{
}

ADReal
FVfromMat::computeQpResidual()
{
  return _u[_qp] - _FE_elem[_qp];
}
