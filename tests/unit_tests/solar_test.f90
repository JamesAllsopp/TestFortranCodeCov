! -----------------------------------------------------------------------------
!
! Copyright (c) 2017 Sam Cox, Roberto Sommariva
!
! This file is part of the AtChem2 software package.
!
! This file is covered by the MIT license which can be found in the file
! LICENSE.md at the top level of the AtChem2 distribution.
!
! -----------------------------------------------------------------------------

module solar_test
  use fruit
  use types_mod
  use solar_functions_mod
  implicit none

contains

  subroutine test_calcTheta
    use date_mod, only : currentYear, currentDayOfYear
    real(kind=DP) :: theta, pi, threshold

    threshold = 1.0e-8_DP
    pi = 4.0_DP * atan( 1.0_DP )

    currentYear = 2000_DI
    currentDayOfYear = 0_DI
    theta = calcTheta()
    call assert_true( theta == 0.0_DP, "calcTheta(), first day of 2000" )
    currentDayOfYear = 365_DI
    theta = calcTheta()
    call assert_true( theta == 2.0_DP*pi*365_DI/366_DI, "calcTheta(), last day of 2000" )

    currentYear = 2001_DI
    currentDayOfYear = 0_DI
    theta = calcTheta()
    call assert_true( theta == 0.0_DP, "calcTheta(), first day of 2001" )
    currentDayOfYear = 364_DI
    theta = calcTheta()
    call assert_true( abs(theta - 2.0_DP*pi*364_DI/365_DI) <= threshold, "calcTheta(), last day of 2001" )

    currentYear = 2004_DI
    currentDayOfYear = 0_DI
    theta = calcTheta()
    call assert_true( theta == 0.0_DP, "calcTheta(), first day of 2004" )
    currentDayOfYear = 365_DI
    theta = calcTheta()
    call assert_true( theta == 2.0_DP*pi*365_DI/366_DI, "calcTheta(), last day of 2004" )

    currentYear = 1900_DI
    currentDayOfYear = 0_DI
    theta = calcTheta()
    call assert_true( theta == 0.0_DP, "calcTheta(), first day of 1900" )
    currentDayOfYear = 364_DI
    theta = calcTheta()
    call assert_true( (theta - 2.0_DP*pi*364_DI/364_DI)<= threshold, "calcTheta(), last day of 1900" )
    
  end subroutine test_calcTheta

end module solar_test
