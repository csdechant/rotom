
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

  ADReal diffusivity;
  interpolate(Moose::FV::InterpMethod::Average,
              diffusivity,
              _diff_elem[_qp],
              _diff_neighbor[_qp],
              *_face_info,
              true);

  return -1.0 * diffusivity * dudn;
}
