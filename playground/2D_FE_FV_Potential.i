#Checked

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    nx = 25
    ny = 25
  []
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [./potential_FE]
  [../]

  [./potential_FV]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]
[]

[Kernels]
#Potential Equations
  [./potential_diffusion_FE]
    type = CoeffDiffusionNonLog
    variable = potential_FE
    position_units = 1.0
  [../]
  [./potential_source_FE]
    type = BodyForce
    variable = potential_FE
    function = 'potential_source'
  [../]
[]

[FVKernels]
#Potential Equations
  [./potential_diffusion_FV]
    type = FVCoeffDiffusionNonLog
    variable = potential_FV
    position_units = 1.0
  [../]
  [./potential_source_FV]
    type = FVBodyForce
    variable = potential_FV
    function = 'potential_source'
  [../]
[]

[AuxVariables]
  [./Potential_FEtoElement]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]

  [./potential_sol_FE]
  [../]
  [./potential_sol_FV]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]

  [./Potential_FV_FEtoElement_Ratio]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[AuxKernels]
  [./Potential_FEtoElement]
    type = QuotientAux
    variable = Potential_FEtoElement
    numerator = potential_FE
    denominator = 1.0
  [../]

  [./potential_sol_Nodel]
    type = FunctionAux
    variable = potential_sol_FE
    function = potential_fun
  [../]
  [./potential_sol_Element]
    type = FunctionAux
    variable = potential_sol_FV
    function = potential_fun
  [../]

  [./Diff_Ratio]
    type = QuotientAux
    variable = Potential_FV_FEtoElement_Ratio
    numerator = potential_FV
    denominator = Potential_FEtoElement
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

[BCs]
  [./potential_FE_left_BC]
    type = FunctionDirichletBC
    variable = potential_FE
    function = 'potential_left_BC'
    boundary = 3
    preset = true
  [../]
  [./potential_FE_right_BC]
    type = FunctionDirichletBC
    variable = potential_FE
    function = 'potential_right_BC'
    boundary = 1
    preset = true
  [../]
  [./potential_FE_down_BC]
    type = FunctionDirichletBC
    variable = potential_FE
    function = 'potential_down_BC'
    boundary = 0
    preset = true
  [../]
  [./potential_FE_up_BC]
    type = FunctionDirichletBC
    variable = potential_FE
    function = 'potential_up_BC'
    boundary = 2
    preset = true
  [../]
[]

[FVBCs]
  [./potential_FV_left_BC]
    type = FVFunctionDirichletBC
    variable = potential_FV
    function = 'potential_left_BC'
    boundary = 3
    preset = true
  [../]
  [./potential_FV_right_BC]
    type = FVFunctionDirichletBC
    variable = potential_FV
    function = 'potential_right_BC'
    boundary = 1
    preset = true
  [../]
  [./potential_FV_down_BC]
    type = FVFunctionDirichletBC
    variable = potential_FV
    function = 'potential_down_BC'
    boundary = 0
    preset = true
  [../]
  [./potential_FV_up_BC]
    type = FVFunctionDirichletBC
    variable = potential_FV
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
    prop_names =  'diffpotential_FE  diffpotential_FV'
    prop_values = 'diffpotential     diffpotential'
  [../]
[]

[Postprocessors]
  [./potential_FE_l2Error]
    type = ElementL2Error
    variable = potential_FE
    function = potential_fun
  [../]

  [./potential_FV_l2Error]
    type = ElementCenterL2Error
    variable = potential_FV
    function = potential_fun
  [../]

  [./potential_FEtoElement_l2Error]
    type = ElementCenterL2Error
    variable = Potential_FEtoElement
    function = potential_fun
  [../]

  [./potential_FV_FEtoElement_l2Diff]
    type = ElementL2Difference
    variable = potential_FV
    other_variable = Potential_FEtoElement
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
  nl_abs_tol = 3e-16 #Needed or will diverge on final TimeStep
[]

[Outputs]
  perf_graph = true
  [./out]
    type = Exodus
  [../]
[]
