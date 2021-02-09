#!/usr/bin/env Rscript 

#zz <- file("/dev/null", open = "wt")
#sink(zz)

library(sessioninfo)
library(dplyr)

#library_location <- readline(prompt="Enter R library path to read from: ")


#  <- "~/Library"
allpkg_filename   <- "all_pkgs.csv"
localpkg_filename <- "local_pkgs.csv"
cranpkg_filename  <- "cran_pkgs.csv"
biocpkg_filename  <- "bioc_pkgs.csv"

save_path                  <- "./Library"
export_path                <- paste( save_path, paste( R.version$major, R.version$minor, sep = "." )  , sep = "/" )
export_allpkgs_location    <- paste( export_path, allpkg_filename   , sep = "/" )
export_cranpkgs_location   <- paste( export_path, cranpkg_filename  , sep = "/" )
export_biocpkgs_location   <- paste( export_path, biocpkg_filename  , sep = "/" )
export_localpkgs_location  <- paste( export_path, localpkg_filename , sep = "/" )

#mkdir $library_location exists
dir.create( toString( save_path ) ) # does not fail if di exists
dir.create( toString( export_path ) )

## list all installed packages
pkgs <- installed.packages()[,'Package']

## read description files & parse using sessioninfo
desc   <- lapply( pkgs, utils::packageDescription )
source <- vapply( desc, sessioninfo:::pkg_source, character( 1 ) )

## combine and filter for appropriate package selection
allpkgs   <- tibble( pkgs, source )
localpkgs <- tibble( pkgs, source ) %>% # grab local packages
    filter(source == "local")

cranpkgs  <- tibble( pkgs, source ) %>% # grab CRAN pacakges
    filter( source ==  paste( "CRAN (R ", paste( R.version$major, R.version$minor, sep = "." ), ")", sep = "" )  )
biocpkgs  <- tibble( pkgs, source ) %>% # grab Bioconductor pacakges
    filter( source == "Bioconductor" ) 
githubpkgs <- tibble( pkgs, source ) %>% # grab packages from github
	filter( source == "Github" )

print( allpkgs   )
print( localpkgs )
print( cranpkgs  )
print( biocpkgs  )
print( githubpkgs )

print( export_allpkgs_location   )
print( export_localpkgs_location )
print( export_cranpkgs_location  )
print( export_biocpkgs_location  )
print( export_githubpkgs_location  )


write.csv( allpkgs,   file = toString( export_allpkgs_location   ) )
write.csv( localpkgs, file = toString( export_localpkgs_location ) )
write.csv( cranpkgs,  file = toString( export_cranpkgs_location  ) )
write.csv( biocpkgs,  file = toString( export_biocpkgs_location  ) )

