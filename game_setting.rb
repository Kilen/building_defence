module BuildingDefence
  PARAMS = {
    wave_interval: 10, #the bigger the easier
    word_density: 5, #the bigger the easier

    #building
    building_height: 3, 
    building_unit: "#",

    #these params should be set in the initialization of the program
    battlefield_width:  0,
    battlefield_height: 0 
  }
  COLORS = {
    letter_typed: 1,
    info: 2,
    error: 3,
    success: 4
  }
end
