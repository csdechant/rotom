[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    #nx = 75
    #ny = 75
    nx = 25
    ny = 25
  []
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [./potential]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]
[]

[FVKernels]
#Potential Equations
  [./potential_diffusion]
    type = FVCoeffDiffusionNonLog
    variable = potential
    position_units = 1.0
  [../]
  #[./ion_charge_source]
  #  type = FVChargeSourceMoles_KVNonLog
  #  variable = potential
  #  charged = em_sol
  #  potential_units = V
  #[../]
  #[./em_charge_source]
  #  type = FVChargeSourceMoles_KVNonLog
  #  variable = potential
  #  charged = ion_sol
  #  potential_units = V
  #[../]
  [./potential_source]
    type = FVBodyForce
    variable = potential
    function = 'potential_source'
  [../]
[]

[AuxVariables]
  [./potential_sol]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]

  [./em_sol]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]

  [./ion_sol]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]
[]

[AuxKernels]
  [./potential_sol]
    type = FunctionAux
    variable = potential_sol
    function = potential_fun
  [../]
[]

[Functions]
#Material Variables
  #Electron diffusion coeff.
  [./diffem_coeff]
    type = ConstantFunction
    value = 0.05
  [../]
  #Electron mobility coeff.
  [./muem_coeff]
    type = ConstantFunction
    value = 0.01
  [../]
  #Ion diffusion coeff.
  [./diffion]
    type = ConstantFunction
    value = 0.1
  [../]
  #Ion mobility coeff.
  [./muion]
    type = ConstantFunction
    value = 0.025
  [../]
  [./N_A]
    type = ConstantFunction
    value = 1.0
  [../]
  [./ee]
    type = ConstantFunction
    value = 1.0
  [../]
  [./diffpotential]
    type = ConstantFunction
    value = 0.01
  [../]


#Manufactured Solutions
  #The manufactured electron density solution
  [./em_fun]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(sin(pi*y) + 0.2*sin(2*pi*t)*cos(pi*y) + 1.0 + cos(pi/2*x)) / N_A'
  [../]
  #The manufactured ion density solution
  [./ion_fun]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(sin(pi*y) + 1.0 + 0.9*cos(pi/2*x)) / N_A'
  [../]
  #The manufactured electron density solution
  [./potential_fun]
    type = ParsedFunction
    vars = 'ee diffpotential'
    vals = 'ee diffpotential'
    value = '-(ee*(2*cos((pi*x)/2) + cos(pi*y)*sin(2*pi*t)))/(5*diffpotential*pi^2)'
  [../]

#Source Terms in moles
  [./potential_source]
    type = ParsedFunction
    vars = 'em_fun ion_fun ee N_A'
    vals = 'em_fun ion_fun ee N_A'
    value = 'ee * (ion_fun - em_fun) * N_A'
  [../]

  #The left BC dirichlet function
  [./potential_left_BC]
    type = ParsedFunction
    vars = 'ee diffpotential'
    vals = 'ee diffpotential'
    value = '-(ee*(cos(pi*y)*sin(2*pi*t) + 2))/(5*diffpotential*pi^2)'
  [../]

  #The right BC dirichlet function
  [./potential_right_BC]
    type = ParsedFunction
    vars = 'ee diffpotential'
    vals = 'ee diffpotential'
    value = '-(ee*cos(pi*y)*sin(2*pi*t))/(5*diffpotential*pi^2)'
  [../]

  #The Down BC dirichlet function
  [./potential_down_BC]
    type = ParsedFunction
    vars = 'ee diffpotential'
    vals = 'ee diffpotential'
    value = '-(ee*(2*cos((pi*x)/2) + sin(2*pi*t)))/(5*diffpotential*pi^2)'
  [../]

  #The up BC dirichlet function
  [./potential_up_BC]
    type = ParsedFunction
    vars = 'ee diffpotential'
    vals = 'ee diffpotential'
    value = '-(ee*(2*cos((pi*x)/2) - sin(2*pi*t)))/(5*diffpotential*pi^2)'
  [../]
[]

[FVBCs]
  [./potential_left_BC]
    type = FVFunctionDirichletBC
    variable = potential
    function = 'potential_left_BC'
    boundary = 3
    preset = true
  [../]
  [./potential_right_BC]
    type = FVFunctionDirichletBC
    variable = potential
    function = 'potential_right_BC'
    boundary = 1
    preset = true
  [../]
  [./potential_down_BC]
    type = FVFunctionDirichletBC
    variable = potential
    function = 'potential_down_BC'
    boundary = 0
    preset = true
  [../]
  [./potential_up_BC]
    type = FVFunctionDirichletBC
    variable = potential
    function = 'potential_up_BC'
    boundary = 2
    preset = true
  [../]
[]

[Materials]
  [./Material_Coeff]
    type = GenericFunctionMaterial
    prop_names =  'e N_A'
    prop_values = 'ee N_A'
  [../]
  [./ADMaterial_Coeff_Set1]
    type = ADGenericFunctionMaterial
    prop_names =  'diffpotential'
    prop_values = 'diffpotential'
  [../]
[]

[Postprocessors]
  [./potential_l2Error]
    type = ElementL2Error
    variable = potential
    function = potential_fun
  [../]

  [./h]
    type = AverageElementSize
  [../]
[]

[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
  [../]

  [./fdp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 20
  #dt = 0.05
  #dt = 0.025
  #dt = 0.01
  dt = 0.008
  #dt = 0.005

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  line_search = none
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'

  scheme = bdf2
[]

[Outputs]
  perf_graph = true
  [./out]
    type = Exodus
  [../]
[]
