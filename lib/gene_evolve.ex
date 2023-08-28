defmodule GeneEvolve do
  import StringOperation

  defp mutation(list_in, population) do
    operations = fn(string) -> [
      rand_shift(string, 3),
      rand_shift(string, 1),
      rand_shift(string, -1),
      rand_shift(string, -3),
      rand_swap(string),
      rand_add(string, 1),
      rand_add(string, 3),
      rand_add(string, 3, true),
      rand_delete(string, 1),
      rand_delete(string, 3),
      rand_delete(string, 3, true)
    ] end
    list_in |> Enum.flat_map(fn string -> operations.(string) end)
            |> Enum.take(population)
  end

  defp mod3_run(string1, string2) do
    len1 = String.length(string1)
    len2 = String.length(string2)

    if len1 == 0 or len2 == 0, do: 0.0

    difference = Enum.zip(String.graphemes(string1), String.graphemes(string2))
                |> Enum.count(fn {x, y} -> x == y end)
                |> then(fn count -> count * 100 / len2 end)

    length_dif = min(len1/len2, len2/len1)

    difference * length_dif
  end



  defp mod4_run(list_in, fitness, fitness_percentile) do
    list_p = Enum.map(list_in, &{mod3_run(&1, fitness), &1})
    fitness_cutoff = trunc(length(list_p) * fitness_percentile)
    Enum.sort(list_p, fn {score1, _}, {score2, _} -> score1 < score2 end)
    |> Enum.drop(-fitness_cutoff)
    |> Enum.map(fn {_, string} -> string end)
  end

  defp mod1_run(list_in, track_in, fitness) do
    # First, compute a list of tuples {score, string}
    scored_list = Enum.map(list_in, &{mod3_run(&1, fitness), &1})

    # Then find the string with the maximum score
    best_e = Enum.max_by(scored_list, fn {score, _string} -> score end)

    list_out = Enum.map(scored_list, &elem(&1, 1))

    track_out = %{
      "lastFit" => track_in["currentFit"],
      "currentFit" => elem(best_e, 0),
      "generationCount" => (track_in["generationCount"] || 0) + 1,
      "bestFit" => max(track_in["bestFit"] || 0, elem(best_e, 0))
    }

    if elem(best_e, 0) == 100 do
      IO.puts "Result Found."
      IO.puts "Generation count = #{track_out["generationCount"]}"
      IO.puts "String :\n #{elem(best_e, 1)}"
    end
    {list_out, track_out}
  end

  defp generate_random_string(length) do
    for _ <- 1..length, into: "", do: <<Enum.random('ACGT')>>
  end

  def generate_initial_population(size, population) do
    for _ <- 1..population, do: generate_random_string(size)
  end

  def run_geneevolve(target_string, fitness_percentile, population_size, initial_string_size) do
    fitness = target_string
    fitness_cutoff = fitness_percentile / 100
    initial_population = generate_initial_population(initial_string_size, population_size)

    {time, _result} = :timer.tc(fn -> evolve(initial_population, fitness, fitness_cutoff, %{"currentFit" => 0.0, "bestFit" => 0.0}, 0) end)

    if time > 10_000_000 do
      IO.puts("Stopped after 10 seconds")
    else
      IO.puts("Finished before 10 seconds")
    end
  end

  defp evolve(population, fitness, fitness_cutoff, track, elapsed_time) do
    if elapsed_time > 10_000_000 or track["bestFit"] == 100 do
      IO.puts("Finished evolution with a best fit of #{track["bestFit"]}")
      track["generationCount"] * length(population)
    else
      {population_next, track_next} = mod1_run(population, track, fitness)
      generation_count = track_next["generationCount"]

      if rem(generation_count, 1000) == 0 || track_next["bestFit"] > track["bestFit"] do
        IO.inspect(generation: generation_count, fitness: track_next["bestFit"])
      end

      {time2, population_next} = :timer.tc(fn -> mutation(population_next, length(population_next)) end)
      {time4, population_next} = :timer.tc(fn -> mod4_run(population_next, fitness, fitness_cutoff) end)

      evolve(population_next, fitness, fitness_cutoff, track_next, elapsed_time + time2 + time4)
    end
  end
end

GeneEvolve.run_geneevolve("ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT", 90, 10000, 50)
