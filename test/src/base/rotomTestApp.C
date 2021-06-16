//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "rotomTestApp.h"
#include "rotomApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
rotomTestApp::validParams()
{
  InputParameters params = rotomApp::validParams();
  return params;
}

rotomTestApp::rotomTestApp(InputParameters parameters) : MooseApp(parameters)
{
  rotomTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

rotomTestApp::~rotomTestApp() {}

void
rotomTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  rotomApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"rotomTestApp"});
    Registry::registerActionsTo(af, {"rotomTestApp"});
  }
}

void
rotomTestApp::registerApps()
{
  registerApp(rotomApp);
  registerApp(rotomTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
rotomTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  rotomTestApp::registerAll(f, af, s);
}
extern "C" void
rotomTestApp__registerApps()
{
  rotomTestApp::registerApps();
}
