#include "rotomApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
rotomApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy material output, i.e., output properties on INITIAL as well as TIMESTEP_END
  params.set<bool>("use_legacy_material_output") = false;

  return params;
}

rotomApp::rotomApp(InputParameters parameters) : MooseApp(parameters)
{
  rotomApp::registerAll(_factory, _action_factory, _syntax);
}

rotomApp::~rotomApp() {}

void
rotomApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAll(f, af, syntax);
  Registry::registerObjectsTo(f, {"rotomApp"});
  Registry::registerActionsTo(af, {"rotomApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
rotomApp::registerApps()
{
  registerApp(rotomApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
rotomApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  rotomApp::registerAll(f, af, s);
}
extern "C" void
rotomApp__registerApps()
{
  rotomApp::registerApps();
}
