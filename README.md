# StlParser

This is a parser for STL files that makes the following assumptions:

1. The files are correctly structured, with only 1 solid
2. There are N facets, where N may be very large
3. There are exactly 3 vertices per facet
4. The file is correctly formed, so no input validation is needed
5. The facets do not overlap, and form a valid solid

The program provides the following output:

1. The number of triangles in the file
2. The surface area of the solid
3. A bounding box that encompasses the solid. **It should be noted that this box is oriented to the coordinate system, rather than the solid so may not always be the minimum possible volume. I stuck to a simpler bounding box for the sake of time**

Performance considerations:

STL files are often very large and may contain millions of triangles. For this reason, it's not practical to load the whole file in memory and loop through the facets. Our code instead streams in the file one facet at a time, and all computations for count, area, and bounding box are done using Elixir streams so that we can stream the whole computation and not load the entirety of the shape into memory. The 2 caveats here are that if the bounding box formula needs to change it may not suit this streaming approach. We also make assumptions that everything is structured correctly and the design is not robust against changes in structure or errors in the file. 

If performance were essential, Elixir wouldn't be the right choice for this program, something lower level and with better library support for STL files would make more sense. 

## Installation

Assuming Elixir 1.10.0:

1. Clone the Repo
2. Fetch the deps with `mix deps.get`
3. Open the application in console with `iex -S mix`
4. Run a parse with `StlParser.parse!("Moon.stl")`, replacing `Moon.stl` with the file you want run
