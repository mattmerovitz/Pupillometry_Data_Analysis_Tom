Tasks to start with:
Generalizing names of functions/files
    STUDY
   
    Remove references to old studies:
        PrP (Prosody and Pupillometry)
        NAPT (Normal Amplitude Pitch Timing Study)
    Rename other functions/files to be more descriptive
       
Compartmentalizing scripts into discrete functions
    THESE STEPS SOULD ALL BE THEIR OWN FUNCTION
    1. De-Blinking (deblink.m)
    2. Linear Interpolation (interpolate.m)
    3. Smoothing data (smooth.m)
    4. Normalization (normalize.m)
    5. Binning (binnig.m)
   
    Once code is ported in new function (and new functions is called correctly)
    Follow these three steps:
        1. Name new function
        2. Run the "process1" script; make sure it still works (fix if it doesn't work now)
        3. remove commented out code that is now in new function