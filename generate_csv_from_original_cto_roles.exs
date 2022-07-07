require Logger

# This file is used to generate the "en_GB" tab template for https://docs.google.com/spreadsheets/d/1ksIW9R3xkP-RHT4iGDAsKom8LVlPiXIphvDedApumT0/edit#gid=645798193
# It takes `roles.json` from bra1n's Townsquare as input (stored as `assets/json/en_GB.json` in this repo)

role_ids = Constants.get_ordered_role_ids()

headers = [
  "id",
  "name",
  "ability",
  "firstNightReminder",
  "otherNightReminder",
  "remindersGlobal",
  "reminders"
]

reversed_headers = Enum.reverse(headers)

defmodule Formatting do
  def col_to_csv(_header, nil), do: nil

  def col_to_csv(header, col) when header in ["reminders", "remindersGlobal"] do
    Enum.join(col, ",")
  end

  def col_to_csv(_header, col) do
    col
  end
end

co_roles =
  "assets/json/en_GB.json"
  |> File.read!()
  |> Jason.decode!()
  |> Enum.reduce(%{}, fn co_role, acc -> Map.put(acc, co_role["id"], co_role) end)

rows =
  Enum.map(role_ids, fn role_id ->
    co_role = co_roles[role_id]

    Enum.reduce(reversed_headers, [], fn header, acc ->
      [Formatting.col_to_csv(header, co_role[header]) | acc]
    end)
  end)

file =
  File.open!("assets/csv/en_GB.csv", [
    :write,
    :utf8
  ])

[headers | rows] |> CSV.encode() |> Enum.each(&IO.write(file, &1))
