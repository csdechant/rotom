
#include "FEElementAverage.h"

#include "Assembly.h"

#include "libmesh/numeric_vector.h"
#include "libmesh/dof_map.h"
#include "libmesh/quadrature.h"
#include "libmesh/boundary_info.h"

registerMooseObject("rotomApp", FEElementAverage);

InputParameters
FEElementAverage::validParams()
{
  InputParameters params = Material::validParams();
  params.addRequiredCoupledVar("var", "The variable to take the element average of.");
  params.addRequiredParam<MaterialPropertyName>(
      "var_average", "The name of the material property to create");
  params.addClassDescription("Give the element average of a variable as a material property.");
  return params;
}

FEElementAverage::FEElementAverage(const InputParameters & parameters)
  : Material(parameters),
    _var_average(declareADProperty<Real>(getParam<MaterialPropertyName>("var_average"))),
    _var_value(adCoupledValue("var")),
    _var(*getVar("var", 0)),

    _current_elem_volume(_assembly.elemVolume()),
    _current_side_volume(_assembly.sideElemVolume()),
    _ad_JxW(_bnd ? _assembly.adJxWFace() : _assembly.adJxW()),
    _ad_coord(_assembly.adCoordTransformation())
{
}

void
FEElementAverage::computeProperties()
{
  if (_constant_option == ConstantTypeEnum::SUBDOMAIN)
    return;

  // Reference to *all* the MaterialProperties in the MaterialData object, not
  // just the ones for this Material.
  MaterialProperties & props = _material_data->props();

  // The qp is a place holder and all qps will be used in ComputeQpProperties().
  _qp = 0;
  computeQpProperties();

  // Now copy the values computed at qp 0 to all the other qps.
  for (const auto & prop_id : _supplied_prop_ids)
  {
    auto nqp = _qrule->n_points();
    for (decltype(nqp) qp = 1; qp < nqp; ++qp)
      props[prop_id]->qpCopy(qp, props[prop_id], 0);
  }
}

void
FEElementAverage::computeQpProperties()
{
  //Taking the element average of all qps
  ADReal value = 0.0;
  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    value += _ad_JxW[_qp] * _ad_coord[_qp] * _var_value[_qp];
  value /= (_bnd ? _current_side_volume : _current_elem_volume);

  //Redefining qp at zero and defining a the average at qp 0
  _qp = 0;
  _var_average[_qp] = value;
}
