
PROGRAM hello
    use types_mod
    use date_mod, only : currentYear, currentDayOfYear
    use  solar_functions_mod    

    real(kind=DP) :: theta, pi

    pi = 4.0_DP * atan( 1.0_DP )

    currentYear = 2000_DI
    currentDayOfYear = 0_DI
    theta = calcTheta()

    ! This is a comment line; it is ignored by the compiler
    print *, 'Hello, World!'
    print *, theta   
 !   theta = calcTheta()
END PROGRAM hello
