defmodule StringOperation do
  @actg "ACTG"

  def rand_shift(str, n) do
    String.slice(str, n..-1) <> String.slice(str, 0..n-1)
  end

  def rand_swap(str) do
    chars = String.graphemes(str)
    len = length(chars)

    if len < 2 do
      str
    else
      ct1 = :rand.uniform(len) - 1
      ct2 = :rand.uniform(len) - 1

      {ct1, ct2} = if ct1 > ct2, do: {ct2, ct1}, else: {ct1, ct2}

      chars
      |> List.replace_at(ct1, Enum.at(chars, ct2))
      |> List.replace_at(ct2, Enum.at(chars, ct1))
      |> Enum.join()
    end
  end

  def rand_mutation(str) do
    chars = String.graphemes(str)
    len = length(chars)

    if len == 0 do
      str
    else
      pos = :rand.uniform(len) - 1
      char = Enum.random(String.graphemes(@actg))

      chars
      |> List.replace_at(pos, char)
      |> Enum.join()
    end
  end

  def rand_add(str, n, consecutive \\ false) do
    actg_graphemes = String.graphemes(@actg)
    chars = String.graphemes(str)

    cond do
      length(chars) == n and not consecutive ->
        str

      consecutive ->
        if length(chars) - n <= 0 do
          str
        else
          insert_at = :rand.uniform(length(chars) - n + 1) - 1
          added = for _ <- 1..n, do: Enum.random(actg_graphemes)
          chars |> List.insert_at(insert_at, added) |> Enum.join()
        end

      true ->
        Enum.reduce(1..n, chars, fn _, acc ->
          if length(acc) == 0 do
            acc
          else
            insert_at = :rand.uniform(length(acc)) - 1
            new_char = Enum.random(actg_graphemes)
            acc |> List.insert_at(insert_at, new_char)
          end
        end) |> Enum.join()
    end
  end

  def rand_delete(str, n, consecutive \\ false) do
    chars = String.graphemes(str)
    len = length(chars)

    if len < n, do: str

    cond do
      len == n and not consecutive ->
        ""

      consecutive ->
        if len - n <= 0 do
          str
        else
          delete_start = :rand.uniform(len - n + 1) - 1
          chars |> delete_consecutive(delete_start, n) |> Enum.join()
        end

      true ->
        Enum.reduce(1..n, chars, fn _, acc ->
          acc_len = length(acc)
          if acc_len <= 0 do
            acc
          else
            delete_at = :rand.uniform(acc_len) - 1
            List.delete_at(acc, delete_at)
          end
        end) |> Enum.join()
    end
  end

  defp delete_consecutive(chars, start, n) do
    prefix = Enum.slice(chars, 0, start)
    suffix = Enum.slice(chars, start+n, length(chars))
    prefix ++ suffix
  end
end
