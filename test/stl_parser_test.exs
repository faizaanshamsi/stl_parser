defmodule StlParserTest do
  use ExUnit.Case
  doctest StlParser

  describe "parse!/1 parses STL input" do
    test "Simple STL file with integers, floats, and negative #s" do
      result = 'Number of Triangles: 2\nSurface Area: 1.8724\nBounding Box: %{x: 0.0, y: -1.0, z: 0.0}, %{x: 0.0, y: -1.0, z: 0.0}, %{x: 0.0, y: 1.0, z: 0.0}, %{x: 0.0, y: 1.0, z: 0.0}, %{x: 1.0, y: -1.0, z: 0.0}, %{x: 1.0, y: -1.0, z: 0.0}, %{x: 1.0, y: 1.0, z: 0.0}, %{x: 1.0, y: 1.0, z: 0.0}\n\n'

      assert StlParser.parse!("simple.stl") == result
    end
  end
end
