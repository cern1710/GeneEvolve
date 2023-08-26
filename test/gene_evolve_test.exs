defmodule GeneEvolveTest do
  use ExUnit.Case
  doctest GeneEvolve

  test "String shifting" do
    assert StringOperation.random_shift("Hello world", 2) == "llo worldHe"
  end
end
