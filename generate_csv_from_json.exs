require Logger

# This file is used to generate the locale tabs for https://docs.google.com/spreadsheets/d/183HMp4ZgslxA4NtFVTXhY3xAbg7FIXZdmVnh9-4A_14/edit#gid=1546765235

defmodule GenerateCsvFromJson do
  def process_json(json_path) do
    # Extract the locale from the json name (format should be "<locale>.json"
    locale =
      json_path
      |> Path.rootname()
      |> Path.basename()

    # Load up clocktower.online roles from the JSON file.
    co_roles =
      json_path
      |> File.read!()
      |> Jason.decode!()
      |> Enum.reduce(%{}, fn co_role, acc -> Map.put(acc, co_role["id"], co_role) end)

    headers = Constants.get_csv_headers()
    reversed_headers = Enum.reverse(headers)

    rows =
      Enum.map(Constants.get_ordered_role_ids(), fn role_id ->
        co_role = co_roles[role_id] || %{"id" => role_id}

        Enum.reduce(reversed_headers, [], fn header, acc ->
          [col_to_csv(header, co_role[header]) | acc]
        end)
      end)

    # Write to csv
    csv_path = "assets/csv/#{locale}.csv"

    file =
      File.open!(csv_path, [
        :write,
        :utf8
      ])

    [headers | rows] |> CSV.encode() |> Enum.each(&IO.write(file, &1))

    Logger.info("File generated at: #{csv_path}\n")
  end

  defp col_to_csv(_header, nil), do: nil

  defp col_to_csv(header, col) when header in ["reminders", "remindersGlobal"] do
    Enum.join(col, ",")
  end

  defp col_to_csv(_header, col) do
    col
  end
end

Constants.get_known_locales()
|> Enum.each(fn locale ->
  path = "assets/json/#{locale}.json"
  GenerateCsvFromJson.process_json(path)
end)
