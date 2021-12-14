require Logger

# Download the csv from https://docs.google.com/spreadsheets/d/1ksIW9R3xkP-RHT4iGDAsKom8LVlPiXIphvDedApumT0/edit#gid=645798193
# In "JSON Generator <LOCALE>" tab
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

    # Load roles from clocktower.online's roles.json file (https://github.com/bra1n/townsquare/blob/develop/src/roles.json). We use this to automatically add data like night order and teams to the translations. "co" stands for clocktower.online.
    co_roles =
      "assets/roles.json"
      |> File.read!()
      |> Jason.decode!()
      |> Enum.reduce(%{}, fn co_role, acc -> Map.put(acc, co_role["id"], co_role) end)

    merged_with_all_co_roles =
      Enum.reduce(
        roles_from_csv,
        [],
        fn row, acc ->
          parsed_co_role = from_csv_row_to_co_role(row)
          role_id = parsed_co_role["id"]
          co_role = co_roles[role_id]
          parsed_co_role = Map.put(parsed_co_role, "id", "#{locale}_#{role_id}")

          parsed_co_role =
            Map.put(
              parsed_co_role,
              "image",
              "https://github.com/bra1n/townsquare/blob/main/src/assets/icons/#{role_id}.png?raw=true"
            )

          [Map.merge(co_role, parsed_co_role) | acc]
        end
      )

    result_json = Jason.encode!(merged_with_all_co_roles)

    json_path = "assets/generated_json/roles_#{locale}.json"
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

args = System.argv()

case length(args) do
  1 ->
    GenerateJsonFromCsv.process_csv(Enum.at(args, 0))

  _other ->
    Logger.error(
      "Wrong number of arguments\nUsage: mix run generate_json_from_csv.exs <path_to_csv>\n"
    )
end