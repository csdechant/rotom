
#include "ElementCenterL2Error.h"
#include "Function.h"

registerMooseObject("rotomApp", ElementCenterL2Error);

defineLegacyParams(ElementCenterL2Error);

InputParameters
ElementCenterL2Error::validParams()
{
  InputParameters params = ElementIntegralVariablePostprocessor::validParams();
  params.addRequiredParam<FunctionName>("function", "The analytic solution to compare against");
  params.addClassDescription(
      "Computes L2 error between a field variable and an analytical function at the centroid of the element");
  return params;
}

ElementCenterL2Error::ElementCenterL2Error(const InputParameters & parameters)
  : ElementIntegralVariablePostprocessor(parameters), _func(getFunction("function"))
{
}

Real
ElementCenterL2Error::getValue()
{
  return std::sqrt(ElementIntegralPostprocessor::getValue());
}

Real
ElementCenterL2Error::computeQpIntegral()
{
  Real diff = _u[_qp] - _func.value(_t, _current_elem->centroid());
  return diff * diff;
}
