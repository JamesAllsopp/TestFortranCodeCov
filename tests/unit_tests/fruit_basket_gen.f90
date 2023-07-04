module fruit_basket_gen
  use fruit
contains
  subroutine solar_test_all_tests
    use solar_test

    write (*, *) "  ..running test: test_calcTheta"
    call set_unit_name('test_calcTheta')
    call run_test_case (test_calcTheta, &
                      &"test_calcTheta")
    if (.not. is_case_passed()) then
      write(*,*) 
      write(*,*) '  Un-satisfied spec:'
      write(*,*) '  -- calcTheta'
      write(*,*) 
      call case_failed_xml("test_calcTheta", &
      & "solar_test")
    else
      call case_passed_xml("test_calcTheta", &
      & "solar_test")
    end if

  end subroutine solar_test_all_tests

  subroutine fruit_basket
    call solar_test_all_tests
  end subroutine fruit_basket

end module fruit_basket_gen