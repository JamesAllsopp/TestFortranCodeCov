program fruit_driver_gen
  use fruit
  use fruit_basket_gen
  call init_fruit
  call init_fruit_xml
  call fruit_basket
  call fruit_summary
  call fruit_summary_xml
  call fruit_finalize
end program fruit_driver_gen
