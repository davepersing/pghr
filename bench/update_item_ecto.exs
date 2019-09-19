alias Pghr.Item
alias Pghr.Repo

IO.puts("Deleting all existing items ...")

Repo.delete_all(Item)

IO.puts("Creating 5,000 new items ...")

count = 5000

item_ids =
  Enum.map(1..count, fn _ ->
    random = :rand.uniform(100_000_000_000_000)

    {:ok, %{id: id}} =
      Repo.insert(%Item{
        mumble1: "mumble",
        mumble2: "Mumble-#{random}",
        mumble3: "Moar Mumble #{random}"
      })

    id
  end)

first_item_id = List.first(item_ids)
last_item_id = first_item_id + count - 1
^last_item_id = List.last(item_ids)

IO.puts("Starting test ...")

ParallelBench.run(
  fn ->
    random_item_id = Enum.random(item_ids)
    random = :rand.uniform(100_000_000_000_000)

    {:ok, _} =
      Item
      |> Repo.get_by(id: random_item_id)
      |> Ecto.Changeset.change(%{mumble3: "New Mumble #{random}"})
      |> Repo.update()
  end,
  parallel: 10,
  duration: 10
)
