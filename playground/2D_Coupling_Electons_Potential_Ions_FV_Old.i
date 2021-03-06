#Checked

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    nx = 10
    ny = 10
  []
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [./em]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]
  [./potential]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]
  [./ion]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]
[]

[FVKernels]
#Electron Equations
  [./em_time_derivative]
    type = FVTimeKernel
    variable = em
  [../]
  [./em_diffusion]
    type = FVCoeffDiffusionNonLog
    variable = em
    position_units = 1.0
  [../]
  [./em_advection]
    type = FVEFieldAdvectionNonLog_OldFVOnlyCoupling
    variable = em
    potential = potential
    position_units = 1.0
  [../]
  [./em_source]
    type = FVBodyForce
    variable = em
    function = 'em_source'
  [../]

#Ion Equations
  [./ion_time_derivative]
    type = FVTimeKernel
    variable = ion
  [../]
  [./ion_diffusion]
    type = FVCoeffDiffusionNonLog
    variable = ion
    position_units = 1.0
  [../]
  [./ion_advection]
    type = FVEFieldAdvectionNonLog_OldFVOnlyCoupling
    variable = ion
    potential = potential
    position_units = 1.0
  [../]
  [./ion_source]
    type = FVBodyForce
    variable = ion
    function = 'ion_source'
  [../]

#Potential Equations
  [./potential_diffusion]
    type = FVCoeffDiffusionNonLog
    variable = potential
    position_units = 1.0
  [../]
  [./ion_charge_source]
    type = FVChargeSourceMoles_KVNonLog
    variable = potential
    charged = em_sol
    potential_units = V
  [../]
  [./em_charge_source]
    type = FVChargeSourceMoles_KVNonLog
    variable = potential
    charged = ion_sol
    potential_units = V
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

  [./em_sol]
    type = FunctionAux
    variable = em_sol
    function = em_fun
  [../]

  [./ion_sol]
    type = FunctionAux
    variable = ion_sol
    function = ion_fun
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
  #The electron source term.
  [./em_source]
    type = ParsedFunction
    vars = 'ee diffpotential diffem_coeff muem_coeff N_A'
    vals = 'ee diffpotential diffem_coeff muem_coeff N_A'
    value = '(diffem_coeff*(pi^2*sin(pi*y) + (pi^2*cos(pi*y)*sin(2*pi*t))/5) +
              (2*pi*cos(2*pi*t)*cos(pi*y))/5 + (diffem_coeff*pi^2*cos((pi*x)/2))/4 +
              (ee*muem_coeff*(5*cos((pi*x)/2) - 4*cos(2*pi*t)^2*cos(pi*y)^2 +
              10*cos(pi*y)*sin(2*pi*t) + 5*cos((pi*x)/2)*sin(pi*y) + 2*cos(2*pi*t)^2 +
              10*cos((pi*x)/2)^2 + 4*cos(pi*y)^2 + 11*cos((pi*x)/2)*cos(pi*y)*sin(2*pi*t) +
              20*cos(pi*y)*sin(2*pi*t)*sin(pi*y) - 7))/(50*diffpotential)) / N_A'
  [../]
  #The ion source term.
  [./ion_source]
    type = ParsedFunction
    vars = 'ee diffpotential diffion muion N_A'
    vals = 'ee diffpotential diffion muion N_A'
    value = '((diffion*pi^2*(9*cos((pi*x)/2) + 40*sin(pi*y)))/40 +
              (9*ee*muion*sin((pi*x)/2)^2)/(100*diffpotential) -
              (ee*muion*cos((pi*x)/2)*((9*cos((pi*x)/2))/10 + sin(pi*y) + 1))/(10*diffpotential) -
              (ee*muion*cos(pi*y)*sin(2*pi*t)*sin(pi*y))/(5*diffpotential) -
              (ee*muion*cos(pi*y)*sin(2*pi*t)*((9*cos((pi*x)/2))/10 +
              sin(pi*y) + 1))/(5*diffpotential)) / N_A'
  [../]

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
  [./em_left_BC]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(sin(pi*y) + (cos(pi*y)*sin(2*pi*t))/5 + 2) / N_A'
  [../]
  [./ion_left_BC]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(sin(pi*y) + 19/10) / N_A'
  [../]

  #The right BC dirichlet function
  [./potential_right_BC]
    type = ParsedFunction
    vars = 'ee diffpotential'
    vals = 'ee diffpotential'
    value = '-(ee*cos(pi*y)*sin(2*pi*t))/(5*diffpotential*pi^2)'
  [../]
  [./em_right_BC]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(sin(pi*y) + (cos(pi*y)*sin(2*pi*t))/5 + 1) / N_A'
  [../]
  [./ion_right_BC]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(sin(pi*y) + 1) / N_A'
  [../]

  #The Down BC dirichlet function
  [./potential_down_BC]
    type = ParsedFunction
    vars = 'ee diffpotential'
    vals = 'ee diffpotential'
    value = '-(ee*(2*cos((pi*x)/2) + sin(2*pi*t)))/(5*diffpotential*pi^2)'
  [../]
  [./em_down_BC]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(cos((pi*x)/2) + sin(2*pi*t)/5 + 1) / N_A'
  [../]
  [./ion_down_BC]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '((9*cos((pi*x)/2))/10 + 1) / N_A'
  [../]

  #The up BC dirichlet function
  [./potential_up_BC]
    type = ParsedFunction
    vars = 'ee diffpotential'
    vals = 'ee diffpotential'
    value = '-(ee*(2*cos((pi*x)/2) - sin(2*pi*t)))/(5*diffpotential*pi^2)'
  [../]
  [./em_up_BC]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(cos((pi*x)/2) - sin(2*pi*t)/5 + 1) / N_A'
  [../]
  [./ion_up_BC]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '((9*cos((pi*x)/2))/10 + 1) / N_A'
  [../]

  [./em_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(3.0 + cos(pi/2*x)) / N_A'
  [../]
  [./ion_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(3.0 + 0.9*cos(pi/2*x)) / N_A'
  [../]
[]

[ICs]
  [./em_ICs]
    type = FunctionIC
    variable = em
    function = em_ICs
  [../]
  [./ion_ICs]
    type = FunctionIC
    variable = ion
    function = ion_ICs
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

  [./em_left_BC]
    type = FVFunctionDirichletBC
    variable = em
    function = 'em_left_BC'
    boundary = 3
    preset = true
  [../]
  [./em_right_BC]
    type = FVFunctionDirichletBC
    variable = em
    function = 'em_right_BC'
    boundary = 1
    preset = true
  [../]
  [./em_down_BC]
    type = FVFunctionDirichletBC
    variable = em
    function = 'em_down_BC'
    boundary = 0
    preset = true
  [../]
  [./em_up_BC]
    type = FVFunctionDirichletBC
    variable = em
    function = 'em_up_BC'
    boundary = 2
    preset = true
  [../]

  [./ion_left_BC]
    type = FVFunctionDirichletBC
    variable = ion
    function = 'ion_left_BC'
    boundary = 3
    preset = true
  [../]
  [./ion_right_BC]
    type = FVFunctionDirichletBC
    variable = ion
    function = 'ion_right_BC'
    boundary = 1
    preset = true
  [../]
  [./ion_down_BC]
    type = FVFunctionDirichletBC
    variable = ion
    function = 'ion_down_BC'
    boundary = 0
    preset = true
  [../]
  [./ion_up_BC]
    type = FVFunctionDirichletBC
    variable = ion
    function = 'ion_up_BC'
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
    prop_names =  'diffpotential diffion muion'
    prop_values = 'diffpotential diffion muion'
  [../]
  [./ADMaterial_Coeff_Set2]
    type = ADGenericFunctionMaterial
    prop_names =  'diffem        muem'
    prop_values = 'diffem_coeff  muem_coeff'
  [../]
  [./Charge_Signs]
    type = GenericConstantMaterial
    prop_names =  'sgnem  sgnion'
    prop_values = '-1.0   1.0'
  [../]
  [./Charge_SignsV02]
    type = GenericConstantMaterial
    prop_names =  'sgnem_sol  sgnion_sol'
    prop_values = '-1.0       1.0'
  [../]
[]

[Postprocessors]
  [./em_l2Error]
    type = ElementL2Error
    variable = em
    function = em_fun
  [../]
  [./ion_l2Error]
    type = ElementL2Error
    variable = ion
    function = ion_fun
  [../]
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
  end_time = 10
  dt = 0.008

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
