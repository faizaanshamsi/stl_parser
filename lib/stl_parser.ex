defmodule StlParser do
  @moduledoc """
  Handles parsing of STL files
  """

  @doc """
  Takes a filename and returns a string literal with number of triangles, surface area, and a bounding box
  """
  def parse!(filename) do
    result = %{
      triangles: 0,
      surface_area: 0.0,
      bounding_box: %{min_x: 0.0, max_x: 0.0, min_y: 0.0, max_y: 0.0, min_z: 0.0, max_z: 0.0}
    }

    output_data =
      filename
      |> File.stream!([], :line)
      |> Stream.drop(1)
      |> Stream.drop(-1)
      |> Stream.chunk_every(7)
      |> Stream.scan(result, fn facet_data, previous_result ->
        parsed_facet_data = parse_facet_data(facet_data)
        area = facet_surface_area(parsed_facet_data)
        bounding_box = update_bounding_box(previous_result.bounding_box, parsed_facet_data)

        %{
          triangles: Map.get(previous_result, :triangles) + 1,
          surface_area: Map.get(previous_result, :surface_area) + area,
          bounding_box: bounding_box
        }
      end)
      |> Enum.at(-1)

    '''
    Number of Triangles: #{output_data.triangles}
    Surface Area: #{format_surface_area(output_data.surface_area)}
    Bounding Box: #{format_bounding_box(output_data.bounding_box)}
    '''
  end

  # We have a nested loop here but it will never be more than 3x3 so it should be okay
  defp parse_facet_data(facet_data) do
    facet_data
    |> Enum.slice(2..4)
    |> Enum.map(fn vertex_data ->      
      Regex.scan(~r/[-+]?[0-9]*\.?[0-9]+/, vertex_data) 
      |> List.flatten
      |> Enum.map(fn value ->
        {result, _} = Float.parse(value)
        result
      end)
    end)
  end

  @doc """
  A = (x1, y1, z1) 
  B = (x2, y2, z2) 
  C = (x3, y3, z3) 

  AB = (x2-x1, y2-y1, z2-z1) 
  AC = (x3-x1, y3-y1, z3-z1) 
    
  Area = 1/2 |AB x AC|
  """
  defp facet_surface_area(data) do
    [x1, y1, z1] = data |> Enum.at(0) 
    [x2, y2, z2] = data |> Enum.at(1)
    [x3, y3, z3] = data |> Enum.at(2) 

    vector_ab = Graphmath.Vec3.create([x2 - x1, y2 - y1, z2 - z1])
    vector_ac = Graphmath.Vec3.create([x3 - x1, y3 - y1, z3 - z1])

    Graphmath.Vec3.length(Graphmath.Vec3.cross(vector_ab, vector_ac)) * 0.5
  end

  @doc """
  This draws a rectangle that's oriented to the axis rather than contains the 
  smallest possible volume around the shape
  """
  defp update_bounding_box(
         bounding_box,
         parsed_facet_data
       ) do
    parsed_facet_data
    |> Enum.reduce(bounding_box, fn vertex, box ->
      [x, y, z] = vertex

      cond do
        x < box.min_x -> 
          Map.put(box, :min_x, x)        
        x > box.min_x -> 
          Map.put(box, :max_x, x)
        y < box.min_y -> 
          Map.put(box, :min_y, y)
        y > box.max_y -> 
          Map.put(box, :max_y, y)
        z < box.min_z -> 
          Map.put(box, :min_z, z)        
        z > box.min_z -> 
          Map.put(box, :max_z, z)
        true -> box
      end
    end)
  end

  defp format_bounding_box(%{
         min_x: min_x,
         max_x: max_x,
         min_y: min_y,
         max_y: max_y,
         min_z: min_z,
         max_z: max_z
       }) do
    '''
    %{x: #{min_x}, y: #{min_y}, z: #{max_z}}, %{x: #{min_x}, y: #{min_y}, z: #{min_z}}, %{x: #{
      min_x
    }, y: #{max_y}, z: #{min_z}}, %{x: #{min_x}, y: #{max_y}, z: #{max_z}}, %{x: #{max_x}, y: #{
      min_y
    }, z: #{max_z}}, %{x: #{max_x}, y: #{min_y}, z: #{min_z}}, %{x: #{max_x}, y: #{max_y}, z: #{
      min_z
    }}, %{x: #{max_x}, y: #{max_y}, z: #{max_z}}
    '''
  end

  defp format_surface_area(surface_area) do
    Float.round(surface_area, 4)
  end
end
