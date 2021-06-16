diff=1.1
a=1.1

[GlobalParams]
  advected_interp_method = 'average'
[]

[Mesh]
  [./gen_mesh]
    type = GeneratedMeshGenerator
    dim = 1
    xmin = -0.6
    xmax = 0.6
    nx = 64
  [../]
[]

[Problem]
  kernel_coverage_check = off
[]

[Variables]
  [./v]
    #family = MONOMIAL
    #order = CONSTANT
    #fv = true
  [../]
[]

#[FVKernels]
[Kernels]
  #[./advection]
  #  type = FVMatAdvection
  #  variable = v
  #  vel = 'fv_velocity'
  #[../]
  [./advection]
    type = EffectiveEFieldAdvectionNonLog
    variable = v
    u = 1.1
    position_units = 1.0
  [../]
  #[./diffusion]
  #  type = FVDiffusion
  #  variable = v
  #  coeff = coeff
  #[../]
  [./diffusion]
    type = ADMatDiffusion
    variable = v
    diffusivity = coeff
  [../]
  #[body_v]
  #  type = FVBodyForce
  #  variable = v
  #  function = 'forcing'
  #[]
  [body_v]
    type = BodyForce
    variable = v
    function = 'forcing'
  []
[]

#[FVBCs]
[BCs]
  #[boundary]
  #  type = FVFunctionDirichletBC
  #  boundary = 'left right'
  #  function = 'exact'
  #  variable = v
  #[]
  [boundary]
    type = FunctionDirichletBC
    boundary = 'left right'
    function = 'exact'
    variable = v
  []
[]

[Materials]
  [diff]
    type = ADGenericConstantMaterial
    prop_names = 'coeff    muv'
    prop_values = '${diff} 1.0'
  []
  #[adv_material]
  #  type = ADCoupledVelocityMaterial
  #  vel_x = '${a}'
  #  rho = 'v'
  #  velocity = 'fv_velocity'
  #[]
  [material]
    type = GenericConstantMaterial
    prop_names = 'sgnv'
    prop_values = '1.0'
  []
[]

[Functions]
  [exact]
    type = ParsedFunction
    value = '3*x^2 + 2*x + 1'
  []
  [forcing]
    type = ParsedFunction
    value = '-${diff}*6 + ${a} * (6*x + 2)'
    # value = '-${diff}*6'
  []
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
[]

[Outputs]
  exodus = true
  csv = true
[]

[Postprocessors]
  [./error]
    type = ElementL2Error
    variable = v
    function = exact
    #outputs = 'console csv'
    execute_on = 'timestep_end'
  [../]
  [h]
    type = AverageElementSize
    #outputs = 'console csv'
    execute_on = 'timestep_end'
  []
[]
