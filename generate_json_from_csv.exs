require Logger

# This script will generate JSON files for clocktower.online and Nara from the google sheet we use for translations:
# Download the csv from https://docs.google.com/spreadsheets/d/183HMp4ZgslxA4NtFVTXhY3xAbg7FIXZdmVnh9-4A_14/edit#gid=1546765235
# In "<LOCALE>" tab

# Usage: mix run generate_json_from_csv.exs

defmodule GenerateJsonFromCsv do
  # Main function
  def process_csv(csv_path) do
    locale =
      csv_path
      |> Path.rootname()
      |> Path.basename()

    roles_from_csv =
      csv_path
      |> File.stream!()
      |> CSV.decode!(headers: true, strip_fields: true)

    parsed_roles_from_csv =
      Enum.reduce(
        roles_from_csv,
        %{},
        fn row, acc ->
          # Convert a csv row to a role map with the same format as the clocktower.online ones.
          parsed_csv_co_role = from_csv_row_to_co_role(row)
          role_id = parsed_csv_co_role["id"]

          parsed_csv_co_role =
            Map.put(
              parsed_csv_co_role,
              "image",
              "https://github.com/bra1n/townsquare/blob/main/src/assets/icons/#{role_id}.png?raw=true"
            )

          # Prune all empty fields.
          pruned_csv_co_role =
            Enum.reject(parsed_csv_co_role, fn {_key, value} ->
              value == nil or value == "" or value == []
            end)
            |> Enum.into(%{})

          Map.put(acc, role_id, pruned_csv_co_role)
        end
      )

    # Load roles from clocktower.online's roles.json file (https://github.com/bra1n/townsquare/blob/develop/src/roles.json). We use this to automatically add data like night order and teams to the translations. "co" stands for clocktower.online.
    co_roles =
      "assets/json/en_UK.json"
      |> File.read!()
      |> Jason.decode!()
      |> Enum.reduce(%{}, fn co_role, acc ->
        Map.put(acc, co_role["id"], co_role)
      end)

    merged_with_all_co_roles =
      Enum.reduce(co_roles, [], fn {co_role_id, co_role}, acc ->
        merged_role =
          case parsed_roles_from_csv[co_role_id] do
            nil ->
              Logger.warn("role_id not found in your csv #{inspect(co_role_id, pretty: true)}\n")
              co_role

            parsed_role ->
              Map.merge(co_role, parsed_role)
          end

        [merged_role | acc]
      end)

    result_json = Jason.encode!(merged_with_all_co_roles)

    json_path = "assets/json/#{locale}.json"
    File.write!(json_path, result_json)

    Logger.info("File generated at: #{json_path}\n")
  end

  @doc """
  Take a row from the csv and transform it into a clocktower.online formatted role. There isn't much to do here actually, except transform comma separated arrays (e.g. "Drunk 3,Drunk 2,Drunk 1,No ability") into actual lists.
  """
  def from_csv_row_to_co_role(
        %{
          "reminders" => reminders,
          "remindersGlobal" => reminders_global
        } = row
      ) do
    parsed_reminders = from_comma_separated_array_to_mapset(reminders)
    parsed_reminders_global = from_comma_separated_array_to_mapset(reminders_global)

    # Overwrite reminders and remindersGlobal with the parsed list.
    %{
      row
      | "reminders" => MapSet.to_list(parsed_reminders),
        "remindersGlobal" => MapSet.to_list(parsed_reminders_global)
    }
  end

  # We use mapsets to automatically de-duplicate our arrays.
  defp from_comma_separated_array_to_mapset(comma_separated_array) do
    case comma_separated_array do
      "" ->
        MapSet.new()

      comma_separated_array ->
        comma_separated_array
        |> String.split(",")
        |> Enum.map(&String.trim(&1))
        |> Enum.into(MapSet.new())
    end
  end
end

Constants.get_known_locales()
|> Enum.each(fn locale ->
  path = "assets/csv/#{locale}.csv"
  GenerateJsonFromCsv.process_csv(path)
end)
