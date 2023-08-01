
PROGRAM hello
    use types_mod
    use date_mod, only : currentYear, currentDayOfYear
    use  solar_functions_mod    
    real(kind=DP) :: theta, pi,test

    pi = 4.0_DP * atan( 1.0_DP )
    test = 123.0_DP
    currentYear = 2000_DI
    currentDayOfYear = 0_DI
    theta = calcTheta()

    ! This is a comment line; it is ignored by the compiler
    print *, 'Hello, World!'
    print *, theta   
    print *, SumCustom(2,5,9)
  CONTAINS
    INTEGER FUNCTION SumCustom(x,y,z)
      IMPLICIT NONE
      INTEGER, INTENT(IN)::x,y,z
      SumCustom = x+y+z
    END FUNCTION SumCustom
    INTEGER FUNCTION ProductCustom(x,y,z)
      IMPLICIT NONE
      INTEGER, INTENT(IN)::x,y,z
      ProductCustom = x*y*z
    END FUNCTION ProductCustom

END PROGRAM hello
